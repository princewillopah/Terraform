provider "aws" {
  region = var.region
}

resource "aws_instance" "this" {
  for_each = var.instances

  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  key_name                    = each.value.key_name
  iam_instance_profile        = each.value.iam_instance_profile
  user_data                   = each.value.user_data
  vpc_security_group_ids      = var.vpc_security_group_ids
  disable_api_termination     = false  # allow termination via console/API if needed
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(
    {
      "Name" = each.key
      "ManagedBy" = "Terraform"
    },
    each.value.tags
  )

  # Prevent accidental replacement if possible
  lifecycle {
    ignore_changes = [
      ami,    # allows in-place AMI updates via SSM or manual patching without replacement
      user_data
    ]
  }
}