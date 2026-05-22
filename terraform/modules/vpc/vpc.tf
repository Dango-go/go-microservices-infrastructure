# Визначаємо локальні змінні для зручності
locals {  
  cluster_name = "go-services-vpc"
  region       = "eu-central-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "go-services-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  

  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]


  enable_dns_hostnames    = true  
  enable_dns_support      = true   # For security you can off this option but for EKS nodes it is required to be true
  map_public_ip_on_launch = true   # For public subnets, set to true to automatically assign public IPs to instances launched in these subnets. For private subnets, set to false and ensure proper NAT gateway configuration for outbound internet access.
 
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1" 
  }
  tags = {
    Environment = var.Environment
    Project     = var.Project
  }
}