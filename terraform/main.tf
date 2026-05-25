module "vpc" {
    source = "./modules/vpc"
    Environment = var.Environment
    Project     = var.Project
}

module "eks" {
    source     = "./modules/eks"
    vpc_id     = module.vpc.vpc_id  # Atach the VPC ID from the VPC module to the EKS module
    subnet_ids = module.vpc.public_subnets
    Environment = var.Environment
    Project     = var.Project
    oidc_id     = var.oidc_id
    aws_account_id = var.aws_account_id
    Region = var.Region
}

module "security" {
    source = "./modules/security"
    vpc_id = module.vpc.vpc_id
    Environment = var.Environment
}