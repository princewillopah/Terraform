resource "aws_vpc_endpoint" "s3-vpc-endpoint" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.s3"  # Use the appropriate service name for your region
  route_table_ids = var.route_table_ids  # Specify the route table IDs if needed
#   subnet_ids      = var.subnet_ids        # Specify the private subnet IDs where the endpoint will be used

policy            = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "*"
      }
    ]
  })


  tags = {
    Name        = "S3 VPC Endpoint"
    Environment = var.environment
  }
}