# AWS RDS PostgreSQL — Terraform Setup

## Architecture

```
Your Laptop
    │
    │ SSH tunnel (port 5433 → 5432)
    ▼
┌─────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                                  │
│                                                     │
│  ┌──────────────────────┐                           │
│  │   Public Subnets     │                           │
│  │  ┌───────────────┐   │                           │
│  │  │  Bastion Host │ ◄─┼── SSH from your IP only   │
│  │  │  (t3.nano)    │   │                           │
│  │  └───────┬───────┘   │                           │
│  └──────────┼───────────┘                           │
│             │ SSH / Postgres tunnel                 │
│  ┌──────────▼───────────┐                           │
│  │   Private Subnets    │                           │
│  │  ┌───────────────┐   │  ┌────────────────────┐   │
│  │  │   App EC2     ├───┼─►│  RDS PostgreSQL    │   │
│  │  │  (t3.small)   │   │  │  (private only)    │   │
│  │  └───────────────┘   │  └────────────────────┘   │
│  └──────────────────────┘                           │
└─────────────────────────────────────────────────────┘


Internet
   │
Internet Gateway
   │
Public Subnet
   └── Bastion Host (SSH access)
          │
          ▼
Private Subnet
   ├── App EC2
   └── PostgreSQL RDS







```

## Prerequisites

1. [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
2. AWS CLI configured (`aws configure`)
3. Two EC2 Key Pairs created in AWS Console → EC2 → Key Pairs:
   - One for the Bastion Host
   - One for the App EC2

---

## Step-by-Step Deployment

### 1. Clone / copy these files

```bash
cd terraform-rds-postgres/
```

### 2. Create your `terraform.tfvars` file

Create a file called `terraform.tfvars` (it's gitignored by default) with:

```hcl
aws_region            = "us-east-1"
project_name          = "myapp"
bastion_key_pair_name = "Princewill-ssh-bayero-sub"   # Name of your key pair in AWS
app_key_pair_name     = "Princewill-ssh-bayero-sub"       # Name of your key pair in AWS
db_password          = "supersecretpassword" # Use a strong password in production!

```

> ⚠️ **Never put your `db_password` in a `.tfvars` file that gets committed to git.**
> Set it as an environment variable instead:
> ```bash
> export TF_VAR_db_password="your-secure-password-here"
> ```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Preview the plan

```bash
terraform plan
```

Review everything before applying. It should show ~20 resources to create.

### 5. Apply

```bash
terraform apply
```

Type `yes` when prompted. Takes ~10 minutes (RDS provisioning is the slow part).


### 6. Grab the outputs

```bash
terraform output
```
<br/>
This will print your RDS endpoint, Bastion IP, and the exact SSH tunnel command.

```yaml
# Result of output
Outputs:

app_connection_string = "postgresql://dbadmin:<PASSWORD>@myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com:5432/appdb"
app_private_ip = "10.0.10.150"
bastion_public_ip = "13.217.149.194"
rds_db_name = "appdb"
rds_endpoint = "myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com:5432"
rds_port = 5432
rds_username = "dbadmin"
ssh_tunnel_command = <<EOT

# ── How to connect from your LOCAL machine ──────────────────────────────────
#
# Step 1: Open an SSH tunnel (run in a separate terminal, keep it open)
	ssh -N -L 5433:myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com:5432:5432 \
    -i /path/to/your/Princewill-ssh-bayero-sub.pem\
    ubuntu@13.217.149.194
#
# Step 2: In another terminal, connect to Postgres via the tunnel
 psql -h localhost -p 5433 -U dbadmin -d appdb
#
# Or use a GUI tool (pgAdmin / TablePlus / DBeaver):
#   Host:     localhost
#   Port:     5433
#   Database: appdb
#   User:     dbadmin
# ─────────────────────────────────────────────────────────────────────────────

EOT


```
---

<br>
<br>

# Connecting to the Database

### From your Local Machine (via SSH tunnel)

The `terraform output ssh_tunnel_command` gives you the exact commands, but in summary:

**Terminal 1 — open the tunnel (keep this running):**
```yaml
# the command format
ssh -N -L 5433:<rds-endpoint>:5432 \
    -i /path/to/bastion-key.pem \
    ubuntu@<bastion-public-ip>

# example:
	ssh -N -L 5433:myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com:5432:5432 \
    -i /path/to/your/Princewill-ssh-bayero-sub.pem \
    ubuntu@13.217.149.194
```

**Terminal 2 — connect with psql:**
<br> This is a saperate terminal

```YAML
psql -h localhost -p 5433 -U dbadmin -d appdb
```

**GUI tools (pgAdmin, TablePlus, DBeaver):**
| Setting  | Value          |
|----------|----------------|
| Host     | localhost      |
| Port     | 5433           |
| Database | appdb          |
| Username | dbadmin        |
| Password | (your password)|
---

### **From the App EC2**

SSH into the App EC2 via the Bastion:
```bash
# Step 0: copy App EC2 sshkey to SSH Bastion
scp -i Princewill-ssh-bayero-sub.pem Princewill-ssh-bayero-sub.pem ubuntu@13.217.149.194:/home/ubuntu/

# Step 1: SSH into Bastion
ssh -i bastion-key.pem -A ubuntu@<bastion-public-ip>
ssh -i Princewill-ssh-bayero-sub.pem -A ubuntu@13.217.149.194 # example


# Step 2: From Bastion, SSH into App EC2 with the EC2 key
ssh -i app-key.pem ubuntu@<app-private-ip>
ssh -i Princewill-ssh-bayero-sub.pem ubuntu@10.0.10.150   # example

# Step 3: Connect to Postgres from App EC2
psql -h <rds-endpoint> -U dbadmin -d appdb
psql -h "myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com" -U dbadmin -d appdb   # example
psql -h myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com -p 5432 -U dbadmin -d appdb   # example

```

<!-- Or use a single ProxyJump command from your local machine:
```bash
ssh -J ec2-user@<bastion-ip> ec2-user@<app-private-ip> -i app-key.pem
ssh -J ubuntu@13.217.149.194 ubuntu@10.0.10.150 -i Princewill-ssh-bayero-sub.pem
``` -->
---
<br>

**NOTE**

You can connect directly from the Bastion to RDS for ONLY manually accessing PostgreSQL, you technically did not need the App EC2 instance; the bastion alone was enough to reach the RDS.

| Resource    | Purpose                    |
| ----------- | -------------------------- |
| Bastion EC2 | Administrative access      |
| App EC2     | Application runtime server |


So If your goal was ONLY: `Admin Access: Laptop(via SSH Tunnel) -> Bastion -> RDS`
- connect to PostgreSQL manually
- run psql
- use pgAdmin
- do admin tasks

<br>Then `bastion alone is sufficient`

BUT if you want to host: `Application Access: Laptop(via Bastion SSH key) -> Bastion (via app ec2 SSH key & the same Private VPC Network as RDS) -> RDS`
- backend APIs
- web applications
- Docker containers
- Spring Boot
- Node.js
- Django
- FastAPI

then `you absolutely need the App EC2 (or ECS/EKS/Lambda/etc.)`

Bastion:
- Public subnet
- Public IP
- SSH only
- Admin access only


App EC2:
- Private subnet
- No public IP
- Runs backend app
- Connects to RDS

# Real Production Example:
Imagine:
```
Frontend Users
       │
       ▼
Load Balancer
       │
       ▼
App EC2 / ECS / Kubernetes
       │
       ▼
RDS PostgreSQL
```

Admin engineers use:
```
Laptop → Bastion → Private resources
```

Applications use:

```
App Server → RDS
```
These are separate concerns.








## What's NOT included (next steps)

This is a beginner setup. Here's what to add as you grow:

| Feature | What to add | Why |
|---|---|---|
| **Secrets Manager** | `aws_secretsmanager_secret` | No more env vars for passwords |
| **IAM DB Auth** | Enable `iam_database_authentication_enabled` | No passwords at all |
| **Multi-AZ** | `multi_az = true` in `rds.tf` | Automatic failover for production |
| **Read replica** | `aws_db_instance` with `replicate_source_db` | Scale read traffic |
| **Enhanced monitoring** | `monitoring_interval = 60` + IAM role | CPU, memory, I/O metrics |
| **Remote state** | S3 backend + DynamoDB locking | Collaborate with a team |
| **Parameter Store** | `aws_ssm_parameter` | Store config values centrally |

---

## Teardown

```bash
terraform destroy
```

> A final RDS snapshot is taken automatically (see `final_snapshot_identifier` in `rds.tf`).
> Delete it manually in the AWS Console → RDS → Snapshots if you don't need it.

---

## Cost Estimate (us-east-1, staging)

| Resource | Type | ~Monthly Cost |
|---|---|---|
| RDS PostgreSQL | db.t3.micro | ~$15 |
| Bastion Host | t3.nano | ~$4 |
| App EC2 | t3.small | ~$15 |
| NAT Gateway | — | ~$33 |
| Storage (20GB gp3) | — | ~$2 |
| **Total** | | **~$69/month** |

> 💡 **To save money in dev:** Stop the EC2 instances and RDS instance when not in use.
> RDS stopped instances restart automatically after 7 days (AWS limitation).
