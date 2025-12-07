# PUBLIC SUBNET ASSOCIATIONS
resource "aws_route_table_association" "pub_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}


# PRIVATE SUBNET ASSOCIATIONS
resource "aws_route_table_association" "pvt_app_1a" {
  subnet_id      = aws_subnet.private_app_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "pvt_app_1b" {
  subnet_id      = aws_subnet.private_app_1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "pvt_app_1c" {
  subnet_id      = aws_subnet.private_app_1c.id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "pvt_data_1a" {
  subnet_id      = aws_subnet.private_data_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "pvt_data_1b" {
  subnet_id      = aws_subnet.private_data_1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "pvt_data_1c" {
  subnet_id      = aws_subnet.private_data_1c.id
  route_table_id = aws_route_table.private.id
}
