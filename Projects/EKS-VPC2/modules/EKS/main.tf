//Creating EKS Cluster
resource "aws_eks_cluster" "eks-cluster" {
  name     = "my-eks-cluster"
  role_arn = "${aws_iam_role.eks-role.arn}"


#   vpc_config {
#     subnet_ids = [for s in data.aws_subnet.subnets : s.id if s.availability_zone != "us-east-1e"]
#   }

# vpc_config {
#     subnet_ids = concat(
#       aws_subnet.public_subnets[*].id,  # Use public subnet IDs
#       aws_subnet.private_subnets[*].id  # Use private subnet IDs
#     )
#   }

vpc_config {
    subnet_ids = var.EKS-Subnet-IDs
  }

  depends_on = [
    aws_iam_role_policy_attachment.EKSClusterPolicy,
    aws_iam_role_policy_attachment.EKSServicePolicy,
    # data.aws_subnet.subnets
  ]
}


//Creating IAM Role for EKS Cluster
resource "aws_iam_role" "eks-role" {
  name = "eks-cluster-role"


  //Writing Policy
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


//Attaching Polices to IAM Role for EKS
resource "aws_iam_role_policy_attachment" "EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-role.name}"
}


resource "aws_iam_role_policy_attachment" "EKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-role.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.master.name
}

#============================================================
# NODE_GROUP#
#============================================================
//Creating a Node Group 1
resource "aws_eks_node_group" "ng1" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "node-group-1"
  node_role_arn   = aws_iam_role.ng-role.arn
  # subnet_ids      = [for s in data.aws_subnet.subnets : s.id if s.availability_zone != "us-east-1e"]
  subnet_ids = var.EKS-Subnet-IDs

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }


  instance_types  = ["t3.micro"]


  remote_access {
    ec2_ssh_key = "eks-key"
    # source_security_group_ids = [aws_security_group.ng-sg.id]
    source_security_group_ids = [var.EKS-SG]
  }   


  depends_on = [
    aws_iam_role_policy_attachment.EKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.EKS_CNI_Policy,
    aws_iam_role_policy_attachment.EC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks-cluster
  ]
}


//Creating Node Group 2
resource "aws_eks_node_group" "ng2" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "node-group-2"
  node_role_arn   = aws_iam_role.ng-role.arn
  # subnet_ids      = [for s in data.aws_subnet.subnets : s.id if s.availability_zone != "us-east-1e"]
   subnet_ids = var.EKS-Subnet-IDs

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }


  instance_types  = ["t3.micro"]


  remote_access {
    ec2_ssh_key = "eks-key"
    # source_security_group_ids = [aws_security_group.ng-sg.id]
    source_security_group_ids = [var.EKS-SG]
  }  


  depends_on = [
    aws_iam_role_policy_attachment.EKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.EKS_CNI_Policy,
    aws_iam_role_policy_attachment.EC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks-cluster
  ]
}


//Created IAM Role for Node Groups
resource "aws_iam_role" "ng-role" {
  name = "eks-ng-role"


  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


//Attaching Policies to IAM Role of Node Groups
resource "aws_iam_role_policy_attachment" "EKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.ng-role.name
}


resource "aws_iam_role_policy_attachment" "EKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.ng-role.name
}


resource "aws_iam_role_policy_attachment" "EC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.ng-role.name
}

#============================================================
# CONNECT TO EKS
#============================================================

//Updating Kubectl Config File
resource "null_resource" "update-kube-config" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name my-eks-cluster"
    #  command = "aws eks update-kubeconfig --region eu-north-1 --name my-eks-cluster"
  }
  depends_on = [
    aws_eks_node_group.ng1,
    aws_eks_node_group.ng2
  ]
}