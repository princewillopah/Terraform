# ////////////////////////////////////
# //   Security Groups Declaration ///
# ////////////////////////////////////


resource "aws_security_group" "elb_security_group" {
  name        = "My-${var.environment}-ELB-SG"
  description = "Security group for the ELB"
  
  tags = {
    Name = "My-${var.environment}-ELB-SG"
  }
}

resource "aws_security_group" "tomcat_app_security_group" {
  name        = "My-${var.environment}-TOMCAT-APPLICATION-SG"
  description = "Security group for the Tomcat application"

  tags = {
    Name = "My-${var.environment}-TOMCAT-APPLICATION-SG"
  }
}

resource "aws_security_group" "backend_services_security_group" {
  name        = "My-${var.environment}-BACKEND-SERVICES-SG"
  description = "Security group for backend services"
  
  tags = {
    Name = "My-${var.environment}-BACKEND-SERVICES-SG"
  }
}


# ////////////////////////////////////
# //   ELB Security Group Rules    ///
# ////////////////////////////////////
# 
resource "aws_security_group_rule" "elb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_security_group.id
}

resource "aws_security_group_rule" "elb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_security_group.id
}

resource "aws_security_group_rule" "elb_egress_tomcat" {
  type                   = "egress"
  from_port              = 8080
  to_port                = 8080
  protocol               = "tcp"
  source_security_group_id = aws_security_group.tomcat_app_security_group.id
  security_group_id      = aws_security_group.elb_security_group.id
}

resource "aws_security_group_rule" "elb_egress_http" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_security_group.id
}

resource "aws_security_group_rule" "elb_egress_https" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.elb_security_group.id
}

# Tomcat Security Group Rules
resource "aws_security_group_rule" "tomcat_ingress" {
  type                   = "ingress"
  from_port              = 8080
  to_port                = 8080
  protocol               = "tcp"
  source_security_group_id = aws_security_group.elb_security_group.id
  security_group_id      = aws_security_group.tomcat_app_security_group.id
}

resource "aws_security_group_rule" "tomcat_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["102.88.43.252/32", "104.248.193.10/32"]  # Replace with your actual IP addresses
  security_group_id = aws_security_group.tomcat_app_security_group.id
}

resource "aws_security_group_rule" "tomcat_ingress_access_tomcat_app" { # Adding Port 8080 to Tomcat Security Group (tomcat_app_security_group) so i can access my backend for security p
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["102.88.43.252/32", "104.248.193.10/32"]  # Replace "your-ip-address" with your actual IP address
  security_group_id = aws_security_group.tomcat_app_security_group.id
}

resource "aws_security_group_rule" "tomcat_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tomcat_app_security_group.id
}

# Backend Services Security Group Rules
resource "aws_security_group_rule" "backend_ingress_mysql" {
  type                   = "ingress"
  from_port              = 3306
  to_port                = 3306
  protocol               = "tcp"
  source_security_group_id = aws_security_group.tomcat_app_security_group.id
  security_group_id      = aws_security_group.backend_services_security_group.id
}

resource "aws_security_group_rule" "backend_ingress_memcache" {
  type                   = "ingress"
  from_port              = 11211
  to_port                = 11211
  protocol               = "tcp"
  source_security_group_id = aws_security_group.tomcat_app_security_group.id
  security_group_id      = aws_security_group.backend_services_security_group.id
}

resource "aws_security_group_rule" "backend_ingress_rabbitmq" {
  type                   = "ingress"
  from_port              = 5672
  to_port                = 5672
  protocol               = "tcp"
  source_security_group_id = aws_security_group.tomcat_app_security_group.id
  security_group_id      = aws_security_group.backend_services_security_group.id
}

resource "aws_security_group_rule" "backend_self_ingress" {
  type                   = "ingress"
  from_port              = 0
  to_port                = 0
  protocol               = "-1"
  source_security_group_id = aws_security_group.backend_services_security_group.id
  security_group_id      = aws_security_group.backend_services_security_group.id
}
resource "aws_security_group_rule" "backend_ingress__ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["102.88.43.252/32", "104.248.193.10/32"]  # Replace with your actual IP addresses
  security_group_id = aws_security_group.backend_services_security_group.id
}

resource "aws_security_group_rule" "backend_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.backend_services_security_group.id
}



# # /////////////////////////////////
# # //   ELB Security Group Rules ///
# # /////////////////////////////////
# resource "aws_security_group_rule" "elb_ingress_http" {
#   type            = "ingress"
#   from_port       = 80
#   to_port         = 80
#   protocol        = "tcp"
#   cidr_blocks     = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.elb_security_group.id
# }

# resource "aws_security_group_rule" "elb_ingress_https" {
#   type            = "ingress"
#   from_port       = 443
#   to_port         = 443
#   protocol        = "tcp"
#   cidr_blocks     = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.elb_security_group.id
# }

# resource "aws_security_group_rule" "elb_egress_tomcat" {
#   type                   = "egress"
#   from_port              = 8080
#   to_port                = 8080
#   protocol               = "tcp"
#   source_security_group_id = aws_security_group.tomcat_app_security_group.id
#   security_group_id = aws_security_group.elb_security_group.id
# }

# resource "aws_security_group_rule" "elb_egress_http" {
#   type            = "egress"
#   from_port       = 80
#   to_port         = 80
#   protocol        = "tcp"
#   cidr_blocks     = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.elb_security_group.id
# }

# resource "aws_security_group_rule" "elb_egress_https" {
#   type            = "egress"
#   from_port       = 443
#   to_port         = 443
#   protocol        = "tcp"
#   cidr_blocks     = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.elb_security_group.id
# }
# # ///////////////////////////////////
# # /// Tomcat Security Group Rules  //
# # ///////////////////////////////////

# resource "aws_security_group_rule" "tomcat_ingress" {
#   type            = "ingress"
#   from_port       = 8080
#   to_port         = 8080
#   protocol        = "tcp"
#   source_security_group_id = aws_security_group.elb_security_group.id
#   security_group_id = aws_security_group.tomcat_app_security_group.id
# }

# resource "aws_security_group_rule" "tomcat_egress" {
#   type            = "egress"
#   from_port       = 0
#   to_port         = 0
#   protocol        = "-1"
#   cidr_blocks     = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.tomcat_app_security_group.id
# }



# # /////////////////////////////////////////////
# # /// Backend Services Security Group Rules  //
# # /////////////////////////////////////////////

# resource "aws_security_group_rule" "backend_ingress_mysql" {
#   type            = "ingress"
#   from_port       = 3306
#   to_port         = 3306
#   protocol        = "tcp"
#   source_security_group_id = aws_security_group.tomcat_app_security_group.id
#   security_group_id = aws_security_group.backend_services_security_group.id
# }

# resource "aws_security_group_rule" "backend_ingress_memcache" {
#   type            = "ingress"
#   from_port       = 11211
#   to_port         = 11211
#   protocol        = "tcp"
#   source_security_group_id = aws_security_group.tomcat_app_security_group.id
#   security_group_id = aws_security_group.backend_services_security_group.id
# }

# resource "aws_security_group_rule" "backend_ingress_rabbitmq" {
#   type            = "ingress"
#   from_port       = 5672
#   to_port         = 5672
#   protocol        = "tcp"
#   source_security_group_id = aws_security_group.tomcat_app_security_group.id
#   security_group_id = aws_security_group.backend_services_security_group.id
# }

# resource "aws_security_group_rule" "backend_self_ingress" {
#   type            = "ingress"
#   from_port       = 0
#   to_port         = 0
#   protocol        = "-1"
#   source_security_group_id = aws_security_group.backend_services_security_group.id
#   security_group_id = aws_security_group.backend_services_security_group.id
# }

# resource "aws_security_group_rule" "backend_egress" {
#   type            = "egress"
#   from_port       = 0
#   to_port         = 0
#   protocol        = "-1"
#   cidr_blocks     = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.backend_services_security_group.id
# }


///////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

# resource "aws_security_group" "elb-security-group" {
#   ingress {
#     description      = "Open port 80 for access of the ELBFrom anywhere"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     # cidr_blocks      = [var.my-ip] only that stated ip will be able to access the ip
#     cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
#   }
#   ingress {
#     description      = "Open port 443 for access of the ELBFrom anywhere"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
#   } 

# #     egress {
# #     description      = "Allow access from the ELB to the Tomcat application on port 8080"
# #     from_port        = 8080
# #     to_port          = 8080
# #     protocol         = "tcp"
# #     security_groups  = [aws_security_group.tomcat-app-security-group.id]
# #   }
# #   egress {
# #     description      = "Allow HTTP and HTTPS outbound traffic"
# #     from_port        = 80
# #     to_port          = 80
# #     protocol         = "tcp"
# #     cidr_blocks      = ["0.0.0.0/0"]
# #   }
# #   egress {
# #     description      = "Allow HTTPS outbound traffic"
# #     from_port        = 443
# #     to_port          = 443
# #     protocol         = "tcp"
# #     cidr_blocks      = ["0.0.0.0/0"]
# #   }

#   egress {
#     description      = "rules to allow access of the resources inside the vpc to the internet"
#     from_port        = 0 # not restricting the request to any port out there is to set the value to 0
#     to_port          = 0 #same here
#     protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
#     cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
#   }

#   tags = {
#     Name = "My--${var.environment-ELB-SG}"
#   }
# }
# # ---------------
# resource "aws_security_group" "tomcat-app-security-group" {
#   ingress {
#     description      = "Open port 80 for access of the ELBFrom anywhere"
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     # cidr_blocks      = [var.my-ip] only that stated ip will be able to access the ip
#     cidr_blocks      = [aws_security_group.elb-security-group.id]  #for all ips to be able to access the ec2
#   }
   
# # egress {
# #     description      = "Allow HTTP and HTTPS outbound traffic"
# #     from_port        = 80
# #     to_port          = 80
# #     protocol         = "tcp"
# #     cidr_blocks      = ["0.0.0.0/0"]
# #   }
# #   egress {
# #     description      = "Allow HTTPS outbound traffic"
# #     from_port        = 443
# #     to_port          = 443
# #     protocol         = "tcp"
# #     cidr_blocks      = ["0.0.0.0/0"]
# #   }
# egress {
#     description      = "Allow HTTP and HTTPS outbound traffic"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "My--${var.environment-TOMCAT-APPLICATION-SG}"
#   }
# }

# # ---------------
# resource "aws_security_group" "backend-services-security-group" {
#   ingress {
#     description      = "Open port 3306 for access of the mysql from Tomcat App"
#     from_port        = 3306
#     to_port          = 3306
#     protocol         = "tcp"
#     cidr_blocks      = [aws_security_group.tomcat-app-security-group.id]  #for all ips to be able to access the ec2
#   }
#   ingress {
#     description      = "Open port 11211 for access of the memcatch from Tomcat App"
#     from_port        = 11211
#     to_port          = 11211
#     protocol         = "tcp"
#     cidr_blocks      = [aws_security_group.tomcat-app-security-group.id]  #for all ips to be able to access the ec2
#   }
#  ingress {
#     description      = "Open port 5672 for access of the memcatch from Tomcat App"
#     from_port        = 5672
#     to_port          = 5672
#     protocol         = "tcp"
#     cidr_blocks      = [aws_security_group.tomcat-app-security-group.id]  #for all ips to be able to access the ec2
#   }
#   ingress {
#     description      = "Allow all traffic within the backend services to interact with each other "
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     security_groups  = [aws_security_group.backend-services-security-group.id]
#   }
# egress {
#     description      = "Allow HTTP and HTTPS outbound traffic"
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "My--${var.environment-BACKEND-SERVICES-SG}"
#   }
# }