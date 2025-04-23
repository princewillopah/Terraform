# VPC with 1 public subnet and a private subnet
This DevOps project repository aims to simplify and enhance your development lifecycle, providing a foundation for building scalable, resilient, and cloud-native applications. Feel free to contribute, open issues, or provide feedback to help us improve and evolve this DevOps ecosystem. Happy coding!

## DevOps Tools and AWS Services:

1. AWS VPC
2. AWS IAM
3. AWS ECR
4. AWS EKS
5. AWS EC2
6. AWS Cloudwatch
7. Jenkins
8. Maven
9. Docker
10. Helm

## Infrastructure Provisioning
1. VPC and more
    1. 3 web public subnets
    2. 3 app private subnets
    3. 3 db private subnets
    4. 1 public route table
    5. 6 private route tables
    6. Internet gateway
    7. NAT gateways
2. IAM 
    1. Roles
        1. EKS cluster - https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html 
            1. AmazonEKSClusterPolicyhttps://us-east-1.console.aws.amazon.com/iam/home?region=ap-southeast-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAmazonEKSClusterPolicy 
        2. EKS node group - https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html 
            1. AmazonEC2ContainerRegistryReadOnly https://us-east-1.console.aws.amazon.com/iam/home?region=ap-southeast-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAmazonEC2ContainerRegistryReadOnly 
            2. AmazonEKS_CNI_Policy https://us-east-1.console.aws.amazon.com/iam/home?region=ap-southeast-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAmazonEKS_CNI_Policy 
            3. AmazonEKSWorkerNodePolicy https://us-east-1.console.aws.amazon.com/iam/home?region=ap-southeast-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAmazonEKSWorkerNodePolicy 
            4. CloudWatchAgentServerPolicy https://us-east-1.console.aws.amazon.com/iam/home?region=ap-southeast-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FCloudWatchAgentServerPolicy This is required for Cloudwatch observability
            5. AWSXrayWriteOnlyAccess https://us-east-1.console.aws.amazon.com/iam/home?region=ap-southeast-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAWSXrayWriteOnlyAccess This is required for Cloudwatch observability
        3. Linux jump server
        4. Jenkins slave
            1. AmazonEC2ContainerRegistryFullAccess https://us-east-1.console.aws.amazon.com/iam/home?region=ap-southeast-1#/policies/details/arn%3Aaws%3Aiam%3A%3Aaws%3Apolicy%2FAmazonEC2ContainerRegistryFullAccess 
3. Key Pairs
    1. Windows jump server
    2. Linux jump server
    3. EKS node group
    4. Jenkins master
    5. Jenkins slave
4. Security groups
    1. Windows jump server
    2. Linux jump server
    3. EKS cluster
    4. EKS node group
    5. Jenkins master
    6. Jenkins slave
5. EC2 - Windows jump server
6. EC2 - Linux jump server
7. EKS cluster
8. EKS node group
9. ECR
10. EC2 -Jenkins master
11. EC2 - Jenkins slave

## Installation and configuration

1. EC2 - Linux jump server
    1. kubectl - https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
2. EC2 - Jenkins master
    1. git - sudo yum install git -y
    2. jenkins - https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/
3. EC2 - Jenkins slave
    1. git - sudo yum install git -y
    2. maven - https://docs.aws.amazon.com/neptune/latest/userguide/iam-auth-connect-prerq.html
    3. docker - https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-docker.html#install-docker-instructions
    4. kubectl - https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
    5. helm - https://docs.aws.amazon.com/eks/latest/userguide/helm.html
    6. java - sudo dnf install java-17-amazon-corretto -y


## Network configuration

### Security groups

1. Windows jump server

| Type          | Protocol      | Port range      | Source              |     
| ------------- |:-------------:|:---------------:|:-------------------:|
| RDP           | TCP           | 3389            | Internet            |



2. Linux jump server


| Type          | Protocol      | Port range      | Source              |     
| ------------- |:-------------:|:---------------:|:-------------------:|
| SSH           | TCP           | 22              | Internet            |


3. EKS cluster


| Type          | Protocol      | Port range      | Source              |     
| ------------- |:-------------:|:---------------:|:-------------------:|
| HTTPS         | TCP           | 443             | Linux Jump Server   |
| HTTPS         | TCP           | 443             | Jenkins slave       |


4. EKS node group


| Type          | Protocol      | Port range      | Source              |     
| ------------- |:-------------:|:---------------:|:-------------------:|
| Custom TCP    | TCP           | 30000-32767     | Windows Jump Server |


5. Jenkins master


| Type          | Protocol      | Port range      | Source              |     
| ------------- |:-------------:|:---------------:|:-------------------:|
| Custom TCP    | TCP           | 8080            | Windows Jump Server |
| SSH           | TCP           | 22              | Jenkins Slave       |

6. Jenkins slave


| Type          | Protocol      | Port range      | Source              |     
| ------------- |:-------------:|:---------------:|:-------------------:|
| SSH           | TCP           | 22              | Windows Jump Server |
| SSH           | TCP           | 22              | Jenkins Master      |





