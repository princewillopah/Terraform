resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.app_vpc.id
  service_name      = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids         = values(aws_subnet.private_data_subnet)[*].id
  security_group_ids = [aws_security_group.ssm_vpce.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.app_vpc.id
  service_name      = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids         = values(aws_subnet.private_data_subnet)[*].id
  security_group_ids = [aws_security_group.ssm_vpce.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.app_vpc.id
  service_name      = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids         = values(aws_subnet.private_data_subnet)[*].id
  security_group_ids = [aws_security_group.ssm_vpce.id]

  private_dns_enabled = true
}

# //-----------------------------------------------
# if you want to specify subnets individually instead of using all private data subnets
# //-----------------------------------------------
# subnet_ids = [
#   aws_subnet.private_data_subnet["us-east-1a"].id,
#   aws_subnet.private_data_subnet["us-east-1b"].id
# ]


