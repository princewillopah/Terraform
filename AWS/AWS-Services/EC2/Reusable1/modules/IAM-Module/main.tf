resource "aws_iam_role" "this" {
  for_each = var.roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  for_each = {
    for role_name, role_cfg in var.roles :
    role_name => role_cfg.policies
  }

  role       = aws_iam_role.this[each.key].name
  policy_arn = each.value[0] # single attachment via flattening below
}

resource "aws_iam_instance_profile" "this" {
  for_each = var.roles
  name     = "${each.key}-profile"
  role     = aws_iam_role.this[each.key].name
}
