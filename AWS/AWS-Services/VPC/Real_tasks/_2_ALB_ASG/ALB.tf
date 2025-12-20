


# ==========================================================================
# ALB + Target Group + Listener + Outputs
# ==========================================================================
# Target group
resource "aws_lb_target_group" "app_target_group" {
  name     = "${var.app_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"

 health_check {
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 3
  }


}
# -----------------------------------------------------------------------------------
# # Register EC2 to Target Group
# resource "aws_lb_target_group_attachment" "web_server_attachment_1" {
#   target_group_arn = aws_lb_target_group.static_tg.arn
#   target_id        = aws_instance.app-Server1.id
#   port             = 80
# }

# resource "aws_lb_target_group_attachment" "web_server_attachment_2" {
#   target_group_arn = aws_lb_target_group.static_tg.arn
#   target_id        = aws_instance.app-Server2.id
#   port             = 80
# }

# # (More scalable, production style) - use fooloop
# resource "aws_lb_target_group_attachment" "web_servers" {
#   for_each = aws_instance.app_servers

#   target_group_arn = aws_lb_target_group.static_tg.arn
#   target_id        = each.value.id
#   port             = 80
# }






# ----------------------------------------------------------------------

# Load Balancer 
resource "aws_lb" "app-alb" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = var.public_subnet_ids # public subnets

  enable_deletion_protection = false

  tags = {
    Name = "${var.app_name}-application-load-balancer"
  }
}
# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = "80"
  protocol          = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_target_group.arn
    }

}







