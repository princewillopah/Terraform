###############################################################################
# SECURITY GROUPS
#
# Think of Security Groups as per-resource firewalls.
# Best practice: each resource gets its own SG with the MINIMUM required access.
#
# Rules here:
#   Bastion SG  ← SSH from your IP only
#   App SG      ← SSH from Bastion only; outbound unrestricted
#   RDS SG      ← Postgres (5432) from App SG + Bastion SG only
###############################################################################

# ─── Bastion Security Group ───────────────────────────────────────────────────

resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Allow SSH only from operator IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from your machine only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
    # ⚠️  local.my_ip is fetched automatically (see main.tf).
    # If you're on a dynamic IP, you may need to re-apply when it changes,
    # OR replace local.my_ip with "0.0.0.0/0" (less secure but easier for dev).
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Environment = var.environment
  }
}

# ─── App EC2 Security Group ───────────────────────────────────────────────────

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "App EC2 SSH from Bastion, unrestricted outbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from Bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Allow all outbound (needed to reach RDS, internet, etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-app-sg"
    Environment = var.environment
  }
}

# ─── RDS Security Group ───────────────────────────────────────────────────────

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  # description = "RDS Postgres — port 5432 from App and Bastion only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from App EC2"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description     = "Postgres from Bastion (so you can use psql / pgAdmin from local)"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # No egress rule needed for RDS — it only receives connections, never initiates them.

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}
