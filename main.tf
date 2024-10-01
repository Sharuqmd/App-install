# Specify the provider
provider "aws" {
  region = var.region
}

# Configure remote state storage
terraform {
  backend "s3" {
    bucket = var.s3_bucket
    key    = "terraform/${terraform.workspace}/terraform.tfstate"
    region = var.region
  }
}

# Dynamically set the cluster name using workspaces
locals {
  cluster_name = "${var.cluster_name}-${terraform.workspace}"
}

# Create a VPC resource
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc-${terraform.workspace}"
  }
}

# Create Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public-subnet-${terraform.workspace}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private-subnet-${terraform.workspace}"
  }
}

# Data source to fetch the availability zones dynamically
data "aws_availability_zones" "available" {}

# Create Security Group
resource "aws_security_group" "eks_sg" {
  vpc_id = aws_vpc.main_vpc.id
  description = "EKS Security Group"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use a module for creating EKS
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  cluster_version = var.k8s_version
  subnets = [
    aws_subnet.public_subnet.id,
    aws_subnet.private_subnet.id
  ]
  vpc_id = aws_vpc.main_vpc.id
  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_type    = "t3.medium"
    }
  }

  # Enable logging only for production
  enable_logging = terraform.workspace == "prod" ? true : false
}

# Provisioners example: Command to be executed after EKS cluster creation
resource "null_resource" "run_commands" {
  provisioner "local-exec" {
    command = "echo EKS cluster ${module.eks.cluster_name} created in ${var.region}"
  }
}

# Output block to show details
output "eks_endpoint" {
  description = "The EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "kubectl_config_command" {
  description = "Command to configure kubectl for this EKS cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${local.cluster_name}"
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_id
}
