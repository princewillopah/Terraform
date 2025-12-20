resource "aws_launch_template" "web_lt" {
  name = "${var.project_name}-lt"

  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Hello from ASG instance!" > /var/www/html/index.html
EOF
  )
}
