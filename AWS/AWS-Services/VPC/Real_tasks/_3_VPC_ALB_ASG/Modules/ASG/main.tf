# =======================================================
# Launch Template for ASG instances
# ======================================================
resource "aws_launch_template" "app_server_launch_template" {
  name_prefix = "${var.app_name}-lt-"

  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  iam_instance_profile { name = var.iam_instance_profile_name }

  network_interfaces {
    security_groups = [aws_security_group.app_sg.id]
    associate_public_ip_address = false
  }

  user_data = base64encode(file("${path.module}/user-data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = { "Name" = "${var.app_name}-app-server" }
  }
}

# ======================================================
# Auto Scaling Group 
# ======================================================

resource "aws_autoscaling_group" "app_auto_scaling_group" {
  name                      = "${var.app_name}-auto-scaling-group"
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size

  vpc_zone_identifier       = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app_server_launch_template.id
    version = "$Latest"
  }

#    target_group_arns = [aws_lb_target_group.app_target_group.arn] #target_group_arns = [var.alb_target_group_arn]
   target_group_arns =  [var.target_group_arn]



  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                     = "Name"
    value                   = "${var.app_name}-server"
    propagate_at_launch     = true
  }

  lifecycle {
    create_before_destroy   = true
  }
}

# # Target tracking policy: keep average requests per target near threshold
# # resource "aws_autoscaling_policy" "tg_target_tracking" {
# #   name                   = "alb-request-count-tracker"
# #   autoscaling_group_name = aws_autoscaling_group.app_auto_scaling_group.name
# #   policy_type            = "TargetTrackingScaling"

# #   target_tracking_configuration {
# #     predefined_metric_specification {
# #       predefined_metric_type = "ALBRequestCountPerTarget"
# #       resource_label         = "${var.alb_arn_suffix}/${var.alb_target_group_name}" # see note below
# #     }
# #     target_value = var.requests_per_target # e.g., 50
# #     disable_scale_in = false
# #   }
# # }

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.app_name}-scaleout"
  autoscaling_group_name = aws_autoscaling_group.app_auto_scaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.app_name}-scalein"
  autoscaling_group_name = aws_autoscaling_group.app_auto_scaling_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
}
