output "private_instance_ip"{ 
value=aws_instance.private_instance.private_ip
}


output "my-private-route-table-id" {
  value = [aws_route_table.private_rt.id]  # Wrap it in brackets to make it a list
}

# output "my-private-rout-table-id"{ 
# value = aws_route_table.private_rt.id
# }