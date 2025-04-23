# VPC with 1 public subnet and a private subnet
++ Both subnets have EC2 instances
++ From the EC2 instance in the public subnet, we ping and connect to the EC2 instance in the private subnet

# Structure
_1a_Two_Subnets_VPC_with_EC2s/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── public_subnet/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── private_subnet/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

# nat gate is included in the public subnet for private subnet to access the internet
