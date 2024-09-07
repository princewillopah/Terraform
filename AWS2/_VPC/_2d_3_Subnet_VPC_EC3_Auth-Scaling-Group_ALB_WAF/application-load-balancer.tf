resource "aws_lb" "myapp-alb" {
  name               = "myapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-security_group.id]
  subnets            = aws_subnet.my_public_subnet[*].id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "myapp-tg" {
  name     = "myapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myapp-vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.myapp-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myapp-tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.myapp-alb.dns_name
}
