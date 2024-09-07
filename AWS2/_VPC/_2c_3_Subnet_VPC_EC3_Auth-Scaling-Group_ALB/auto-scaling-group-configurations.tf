resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  min_size           = 2
  max_size           = 4
  desired_capacity   = 2
  vpc_zone_identifier = aws_subnet.my_public_subnet[*].id

  target_group_arns = [aws_lb_target_group.myapp-tg.arn]

  tag {
    key                 = "Name"
    value               = "ASG-Instance"
    propagate_at_launch = true
  }
}
