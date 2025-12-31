# resource "aws_instance" "fleet" {
#   for_each = var.instances

#   ami                    = each.value.ami
#   instance_type          = each.value.instance_type
#   subnet_id              = each.value.subnet_id
#   key_name               = each.value.key_name
#   vpc_security_group_ids = each.value.security_groups

#   associate_public_ip_address = lookup(each.value, "associate_public_ip", false)  // If each.value contains "associate_public_ip" = true, the instance gets a public IP; otherwise, it does not.
#   iam_instance_profile        = lookup(each.value, "my_iam_instance_profile", null)
#   disable_api_termination     = false  # allow termination via console/API if needed
#   user_data                   = lookup(each.value, "user_data", null)
#   root_block_device {
#     volume_size = lookup(each.value, "root_volume_size", 20)
#     volume_type = "gp3"
#     encrypted   = true
#   }

#   tags = merge(
#     {
#       Name = "${each.value.app_name}-server"
#     },
#     each.value.tags
#   )
# }



resource "aws_instance" "this" {
  for_each = var.subnet_map

  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = each.value.subnet_id

  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip

  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.app_name}-${var.role_name}-${each.key}"
    env  = var.env
    role = var.role_name
  }
}
