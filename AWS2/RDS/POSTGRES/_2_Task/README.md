
  Laptop
    │
AWS IAM + SSM
    │
Private EC2
    │
   RDS

### Important Caveat

SSM only works if EC2 can reach AWS SSM endpoints.
- Currently we are using NAT Gateway to provide communication between EC2 and AWS SSM endpoints.
- Without NAT:
   -  We would need VPC endpoints.

Best Practice Version Of Your App EC2

Your EC2 should become:

| Setting       | Value       |
| ------------- | ----------- |
| Public IP     | false       |
| SSH ingress   | none        |
| IAM Role      | SSM enabled |
| Access method | SSM         |
| RDS access    | SG to SG    |



Your Laptop
     │
AWS IAM Auth
     │
SSM Session Manager
     │
Private EC2 / EKS Nodes
     │
    RDS
---
### What You Need For SSM To Work
An EC2 instance needs:
| Requirement                           | Why                        |
| ------------------------------------- | -------------------------- |
| IAM Role                              | permissions to talk to SSM |
| SSM Agent                             | installed on EC2           |
| Internet(via NAT   ) OR VPC endpoints | reach AWS SSM service      |

Good news:

- Ubuntu AWS AMIs already include SSM agent usually
   - this is only possible if the EC2 can access the internet to download the components to install the SSM agent and its only possible via nat
- our NAT Gateway already gives outbound internet

<br>
So you mainly need:

- IAM Role
- Instance Profile


Important: NAT Gateway Still Required

Right now your App EC2 needs outbound internet for:

- apt install
- SSM communication
- package downloads

So KEEP:
- NAT Gateway
- public subnet because of NAT



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
app_private_ip = "10.0.10.150" #assuming
rds_db_name = "appdb"
rds_endpoint = "myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com:5432"
rds_port = 5432
rds_username = "dbadmin"
ssh_tunnel_command = <<EOT

# ── How to connect from your LOCAL machine ──────────────────────────────────
#
# Step 1: Open an SSH tunnel (run in a separate terminal, keep it open)
aws ssm start-session --target i-0e538dfb5a455fe87
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
# connect to the ec2 via ssm
aws ssm start-session --target ec2-instance-id # command
aws ssm start-session --target i-0e538dfb5a455fe87 # example

# Install PostgreSQL Client Manually if TF didnt install 
sudo apt update
psql --version
sudo apt install -y postgresql-client
psql --version

# connect to postgress
psql -h myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com -p 5432 -U dbadmin -d appdb

# Test
\l
\dt


# toubleshooting if connection fails
nc -zv myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com 5432
```

**GUI tools (pgAdmin, TablePlus, DBeaver):**
| Setting  | Value          |
|----------|----------------|
| Host     | myapp-staging-postgres.ck7ecsq00r21.us-east-1.rds.amazonaws.com      |
| Port     | 5433           |
| Database | appdb          |
| Username | dbadmin        |
| Password | (your password)|
---

### **Debugging User Data**
If installs fail again:
check:
```
sudo cloud-init status
```

and

```
sudo cat /var/log/cloud-init-output.log
```





































