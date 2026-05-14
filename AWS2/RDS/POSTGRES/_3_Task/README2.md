# Production-Style AWS Private Infrastructure with Packer Golden AMI + SSM + RDS (Terraform)

## Goal

Build a modern AWS infrastructure with:

* Private EC2 instances
* Private RDS PostgreSQL
* AWS Systems Manager (SSM)
* No Bastion Host
* No SSH
* No public EC2 IPs
* Golden AMI built with Packer
* Optional removal of NAT Gateway later

This setup mirrors modern enterprise AWS infrastructure.

---

# Final Architecture

```text
Laptop
   │
AWS IAM Identity
   │
AWS SSM Session Manager
   │
VPC Endpoints (SSM)
   │
Private App EC2 (Golden AMI)
   │
Private RDS PostgreSQL
```

---

# Why Use Golden AMIs?

Instead of:

```bash
apt install docker
apt install postgresql-client
```

on every EC2 boot,

we bake everything into the AMI beforehand.

Benefits:

* Faster EC2 boot time
* Predictable infrastructure
* No internet dependency
* Better security
* Immutable infrastructure
* Easier scaling
* Enterprise standard

---

# What Will Be Preinstalled?

Our Golden AMI will contain:

* Docker
* PostgreSQL client
* AWS SSM Agent
* curl
* unzip
* git
* CloudWatch Agent (optional)
* kubectl (optional)

---

# Folder Structure

```text
terraform/
│
├── ec2.tf
├── iam.tf
├── networking.tf
├── rds.tf
├── security_groups.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── vpc-endpoints.tf
│
packer/
│
├── ubuntu-golden.pkr.hcl
└── scripts/
    └── install.sh
```

---

# PART 1 — Build Golden AMI with Packer

---

# Install Packer

## Ubuntu / WSL

```bash
sudo apt update
sudo apt install -y wget unzip

wget https://releases.hashicorp.com/packer/1.12.0/packer_1.12.0_linux_amd64.zip
unzip packer_1.12.0_linux_amd64.zip
sudo mv packer /usr/local/bin/

packer version
```

---

# Packer File

## `packer/ubuntu-golden.pkr.hcl`

```hcl
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  region = "us-east-1"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["099720109477"]
  }

  instance_type = "t3.micro"
  ssh_username  = "ubuntu"

  ami_name = "golden-ubuntu-24-{{timestamp}}"
}

build {
  name = "golden-ubuntu"

  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    script = "scripts/install.sh"
  }
}
```

---

# Install Script

## `packer/scripts/install.sh`

```bash
#!/bin/bash
set -eux

sudo apt update -y

sudo apt install -y \
  docker.io \
  postgresql-client \
  unzip \
  curl \
  git \
  ca-certificates

# Enable Docker
sudo systemctl enable docker
sudo systemctl start docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify SSM Agent
sudo snap install amazon-ssm-agent --classic || true
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service || true
```

---

# Build the AMI

```bash
cd packer

packer init .
packer validate ubuntu-golden.pkr.hcl
packer build ubuntu-golden.pkr.hcl
```

At the end:

```text
AMI: ami-xxxxxxxxxxxx
```

Save this AMI ID.

---

# PART 2 — Terraform Infrastructure

---

# Networking Design

## Recommended Learning Setup

Keep:

* Private subnets
* NAT Gateway
* SSM
* VPC endpoints

Remove:

* Bastion
* SSH
* Public EC2 IPs

---

# Why Keep NAT Initially?

Because:

* Docker pulls need internet
* apt updates need internet
* kubectl downloads may need internet
* EKS tooling often requires internet

Later you can fully remove NAT.

---

# Terraform — Variables

## `variables.tf`

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "luxecart"
}

variable "environment" {
  default = "staging"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "golden_ami_id" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}
```

---

# Terraform — IAM for SSM

## `iam.tf`

```hcl
resource "aws_iam_role" "ssm_role" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}
```

---

# Terraform — EC2

## `ec2.tf`

```hcl
resource "aws_instance" "app" {
  ami           = var.golden_ami_id
  instance_type = "t3.small"

  subnet_id = aws_subnet.private[0].id

  associate_public_ip_address = false

  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-app"
  }
}
```

---

# Terraform — App Security Group

## `security_groups.tf`

```hcl
resource "aws_security_group" "app" {
  name   = "${var.project_name}-app-sg"
  vpc_id = aws_vpc.main.id

  # No inbound rules

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

---

# Terraform — RDS Security Group

```hcl
resource "aws_security_group" "rds" {
  name   = "${var.project_name}-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}
```

---

# Terraform — RDS

## `rds.tf`

```hcl
resource "random_id" "snapshot" {
  byte_length = 4
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "appdb"
  username = "dbadmin"
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false

  deletion_protection = false

  skip_final_snapshot = true

  multi_az = false
}
```

---

# Terraform — SSM VPC Endpoints

## `vpc-endpoints.tf`

```hcl
resource "aws_security_group" "vpce" {
  name   = "${var.project_name}-vpce-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
}
```

---

# Terraform Apply

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

---

# Start SSM Session

Find EC2 instance ID:

```bash
aws ec2 describe-instances
```

Connect:

```bash
aws ssm start-session --target i-xxxxxxxx
```

---

# Connect to PostgreSQL

Inside SSM session:

```bash
psql \
  -h YOUR_RDS_ENDPOINT \
  -U dbadmin \
  -d appdb
```

---

# OPTIONAL — Fully Remove NAT Gateway

After moving fully private:

Delete:

* NAT Gateway
* Elastic IP
* Private subnet default internet route

BUT:

You must then use:

* ECR VPC endpoints
* S3 gateway endpoints
* Private package mirrors
* Prebaked AMIs only

---

# Enterprise Evolution Path

## Stage 1

* NAT
* SSM
* Golden AMI
* Private EC2
* Private RDS

## Stage 2

Add:

* CloudWatch Agent
* Secrets Manager
* KMS
* ECR
* S3 endpoints

## Stage 3
Remove NAT completely.

Use:
* Immutable AMIs
* ECR only
* Fully private VPC endpoints
* No internet access whatsoever

---

# Security Improvements Achieved

| Feature                  | Status |
| ------------------------ | ------ |
| No Bastion               | ✅      |
| No SSH                   | ✅      |
| No Public EC2 IP         | ✅      |
| IAM-based access         | ✅      |
| Encrypted storage        | ✅      |
| Private RDS              | ✅      |
| Security Group isolation | ✅      |
| Immutable infrastructure | ✅      |
| SSM logging/auditability | ✅      |

---

# Important Production Recommendations

## Use Secrets Manager

Do NOT hardcode DB passwords.

---

## Enable CloudWatch Agent

For:

* metrics
* logs
* observability

---

## Enable Multi-AZ RDS

Production:

```hcl
multi_az = true
```

---

## Enable Deletion Protection

Production:

```hcl
deletion_protection = true
```

---

## Add Backups

```hcl
backup_retention_period = 7
```

---

# What You Have Learned

By building this setup you now understand:

* VPC design
* Public vs private networking
* NAT Gateway purpose
* VPC endpoints
* SSM Session Manager
* IAM instance profiles
* Golden AMIs
* Immutable infrastructure
* RDS private access
* Terraform modular infrastructure
* Enterprise AWS security practices
* Production-grade access patterns

This is already very close to real-world cloud engineering infrastructure.



I’ve provided a full production-style setup covering:

* Packer Golden AMI creation
* Terraform infrastructure
* SSM Session Manager
* Private EC2 + private RDS
* VPC endpoints
* IAM roles
* Security groups
* NAT vs no-NAT architecture
* Enterprise evolution path
* Production hardening recommendations

It’s structured step-by-step so you can build and understand the entire flow end-to-end.
