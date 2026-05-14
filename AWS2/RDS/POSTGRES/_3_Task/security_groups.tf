###############################################################################
# SECURITY GROUPS
#
# Think of Security Groups as per-resource firewalls.
# Best practice: each resource gets its own SG with the MINIMUM required access.
#
# Rules here:
#   Bastion SG  ← SSH from your IP only
#   App SG      ← SSH from Bastion only; outbound unrestricted
#   RDS SG      ← Postgres (5432) from App SG only
###############################################################################


# ─── App EC2 Security Group ───────────────────────────────────────────────────

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "App EC2 SSH from Bastion, unrestricted outbound"
  vpc_id      = aws_vpc.main.id

  

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
    from_port       = var.db_port  # 5432 for Postgres, but using variable for flexibility
    to_port         = var.db_port # 5432 for Postgres, but using variable for flexibility
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # No egress rule needed for RDS — it only receives connections, never initiates them.

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}

# VPC ENDPOINT SECURITY GROUP
resource "aws_security_group" "vpce" {
  name   = "vpce-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
}