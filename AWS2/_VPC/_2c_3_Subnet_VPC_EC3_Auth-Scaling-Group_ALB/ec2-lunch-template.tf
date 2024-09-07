resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0914547665e6a707c" # for eu-north-1
  instance_type = "t3.micro"
  key_name      = aws_key_pair.key_pair.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2-security_group.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  # user_data = file("user-data.sh")
  user_data = base64encode(file("user-data.sh"))
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Server"
    }
  }
}
