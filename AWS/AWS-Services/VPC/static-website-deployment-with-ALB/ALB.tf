


# ==========================================================================
# ALB + Target Group + Listener + Outputs
# ==========================================================================
# Target group
resource "aws_lb_target_group" "static_tg" {
  name     = "static-site-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
}
# -----------------------------------------------------------------------------------
# Register EC2 to Target Group
resource "aws_lb_target_group_attachment" "web_server_attachment_1" {
  target_group_arn = aws_lb_target_group.static_tg.arn
  target_id        = aws_instance.app-Server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_attachment_2" {
  target_group_arn = aws_lb_target_group.static_tg.arn
  target_id        = aws_instance.app-Server2.id
  port             = 80
}

## (More scalable, production style) - use fooloop
# resource "aws_lb_target_group_attachment" "web_servers" {
#   for_each = aws_instance.app_servers

#   target_group_arn = aws_lb_target_group.static_tg.arn
#   target_id        = each.value.id
#   port             = 80
# }








# ----------------------------------------------------------------------

# Load Balancer 
resource "aws_lb" "static-alb" {
  name               = "static-website-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-0b852f6ec3f54351a","subnet-04a377a4140bd105d"] # public subnets

  enable_deletion_protection = false

  tags = {
    Name = "static-website-alb"
  }
}
# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.static-alb.arn
  port              = "80"
  protocol          = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.static_tg.arn
    }

}







