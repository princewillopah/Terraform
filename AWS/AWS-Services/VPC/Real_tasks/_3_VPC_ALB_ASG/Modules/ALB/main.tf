# ==========================================================================
# Target Group 
# ==========================================================================
# Target group

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.app_name}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# --------------------------------------------------------------------------
# Load Balancer
# --------------------------------------------------------------------------
resource "aws_lb" "app_alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.app_name}-alb"
  }
}


# --------------------------------------------------------------------------
# HTTP Listener (80 → redirect to HTTPS)
# --------------------------------------------------------------------------
resource "aws_lb_listener" "app_alb_http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  # default_action { # forward to target group
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.app_tg.arn
  # }

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}




# --------------------------------------------------------------------------
# HTTPS Listener (443 → target group)
# --------------------------------------------------------------------------
resource "aws_lb_listener" "app_alb_https_listener" {
  count = var.certificate_arn != null ? 1 : 0  #//only create if cert ARN provided

  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn  = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}






