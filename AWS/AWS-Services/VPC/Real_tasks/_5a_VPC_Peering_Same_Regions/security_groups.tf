resource "aws_security_group" "allow_internal_a" {
  name   = "allow-internal"
  vpc_id = aws_vpc.vpc_a.id

  ingress {
  protocol    = "icmp"
  from_port   = -1
  to_port     = -1
  cidr_blocks = ["10.11.0.0/16", "10.12.0.0/16"]
}
# Optional: ICMP from internet (for testing only)
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }


  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}

resource "aws_security_group" "allow_internal_b" {
  name   = "allow-internal"
  vpc_id = aws_vpc.vpc_b.id

ingress {
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["10.10.0.0/16", "10.11.0.0/16", "10.12.0.0/16"]
}

ingress {
  protocol    = "icmp"
  from_port   = -1
  to_port     = -1
  cidr_blocks = ["10.10.0.0/16", "10.11.0.0/16", "10.12.0.0/16"]
}
# Optional: ICMP from internet (for testing only)
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}


resource "aws_security_group" "allow_internal_c" {
  name   = "allow-internal"
  vpc_id = aws_vpc.vpc_c.id

ingress {
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["10.10.0.0/16", "10.11.0.0/16", "10.12.0.0/16"]
}

ingress {
  protocol    = "icmp"
  from_port   = -1
  to_port     = -1
  cidr_blocks = ["10.10.0.0/16", "10.11.0.0/16", "10.12.0.0/16"]
}
# Optional: ICMP from internet (for testing only)
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}