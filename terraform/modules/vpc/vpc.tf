# Визначаємо локальні змінні для зручності
locals {  
  cluster_name = "astronomy-shop-cluster"
  region       = "eu-central-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "astronomy-shop-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  

  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]


  enable_dns_hostnames   = true  
  enable_dns_support     = true  

 
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1" 
  }
  tags = {
    Environment = var.Environment
    Project     = var.Project
  }
}