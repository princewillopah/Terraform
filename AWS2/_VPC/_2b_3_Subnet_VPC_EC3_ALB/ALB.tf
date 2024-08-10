
#######---------------------------------------
####### ALB Security Group
#######---------------------------------------
resource "aws_security_group" "alb_security_group" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-security-group"
  }
}

#######---------------------------------------
####### ALB Setup
#######---------------------------------------

resource "aws_lb" "myapp_alb" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = aws_subnet.my_public_subnet[*].id

  # enable_deletion_protection = true

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }


  tags = {
    Name = "${var.environment}-alb"
  }
}
# ---------------------

#######---------------------------------------
####### ALB Listener
#######---------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.myapp_alb.arn
  port              = "80"
  protocol          = "HTTP"

#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.myapp_tg.arn
  }
}


# resource "aws_lb_listener_certificate" "example" {
#   listener_arn    = aws_lb_listener.front_end.arn
#   certificate_arn = aws_acm_certificate.example.arn
# }

#######---------------------------------------
####### Target Group
#######---------------------------------------

resource "aws_lb_target_group" "myapp_tg" {
  name     = "${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myapp-vpc.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.environment}-tg"
  }
}



#######---------------------------------------
####### Register Instances to Target Group
#######---------------------------------------


resource "aws_lb_target_group_attachment" "myapp_tg_attachment" {
  count            = length(var.public_subnet_cidrs)
  target_group_arn = aws_lb_target_group.myapp_tg.arn
  target_id        = aws_instance.EKS-Bootstrap-Server[count.index].id
  port             = 80
}



#######---------------------------------------
####### Instance Target Group
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------




#######---------------------------------------
####### 
#######---------------------------------------






#######---------------------------------------
####### aws_lb_listener_rule
#######---------------------------------------

# resource "aws_lb" "front_end" {
#   # ...
# }

# resource "aws_lb_listener" "front_end" {
#   # Other parameters
# }

# resource "aws_lb_listener_rule" "static" {
#   listener_arn = aws_lb_listener.front_end.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.static.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/static/*"]
#     }
#   }

#   condition {
#     host_header {
#       values = ["example.com"]
#     }
#   }
# }

# # Forward action

# resource "aws_lb_listener_rule" "host_based_weighted_routing" {
#   listener_arn = aws_lb_listener.front_end.arn
#   priority     = 99

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.static.arn
#   }

#   condition {
#     host_header {
#       values = ["my-service.*.terraform.io"]
#     }
#   }
# }

# # Weighted Forward action

# resource "aws_lb_listener_rule" "host_based_routing" {
#   listener_arn = aws_lb_listener.front_end.arn
#   priority     = 99

#   action {
#     type = "forward"
#     forward {
#       target_group {
#         arn    = aws_lb_target_group.main.arn
#         weight = 80
#       }

#       target_group {
#         arn    = aws_lb_target_group.canary.arn
#         weight = 20
#       }

#       stickiness {
#         enabled  = true
#         duration = 600
#       }
#     }
#   }

#   condition {
#     host_header {
#       values = ["my-service.*.terraform.io"]
#     }
#   }
# }

# # Redirect action

# resource "aws_lb_listener_rule" "redirect_http_to_https" {
#   listener_arn = aws_lb_listener.front_end.arn

#   action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }

#   condition {
#     http_header {
#       http_header_name = "X-Forwarded-For"
#       values           = ["192.168.1.*"]
#     }
#   }
# }

# # Fixed-response action

# resource "aws_lb_listener_rule" "health_check" {
#   listener_arn = aws_lb_listener.front_end.arn

#   action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "HEALTHY"
#       status_code  = "200"
#     }
#   }

#   condition {
#     query_string {
#       key   = "health"
#       value = "check"
#     }

#     query_string {
#       value = "bar"
#     }
#   }
# }

# # Authenticate-cognito Action

# resource "aws_cognito_user_pool" "pool" {
#   # ...
# }

# resource "aws_cognito_user_pool_client" "client" {
#   # ...
# }

# resource "aws_cognito_user_pool_domain" "domain" {
#   # ...
# }

# resource "aws_lb_listener_rule" "admin" {
#   listener_arn = aws_lb_listener.front_end.arn

#   action {
#     type = "authenticate-cognito"

#     authenticate_cognito {
#       user_pool_arn       = aws_cognito_user_pool.pool.arn
#       user_pool_client_id = aws_cognito_user_pool_client.client.id
#       user_pool_domain    = aws_cognito_user_pool_domain.domain.domain
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.static.arn
#   }
# }

# # Authenticate-oidc Action

# resource "aws_lb_listener_rule" "oidc" {
#   listener_arn = aws_lb_listener.front_end.arn

#   action {
#     type = "authenticate-oidc"

#     authenticate_oidc {
#       authorization_endpoint = "https://example.com/authorization_endpoint"
#       client_id              = "client_id"
#       client_secret          = "client_secret"
#       issuer                 = "https://example.com"
#       token_endpoint         = "https://example.com/token_endpoint"
#       user_info_endpoint     = "https://example.com/user_info_endpoint"
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.static.arn
#   }
# }


