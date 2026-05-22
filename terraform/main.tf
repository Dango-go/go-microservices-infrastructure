module "vpc" {
    source = "./modules/vpc"
    Environment = var.Environment
    Project     = var.Project
}

module "eks" {
    source     = "./modules/eks"
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.public_subnets
    Environment = var.Environment
    Project     = var.Project
}

module "security" {
    source = "./modules/security"
    vpc_id = module.vpc.vpc_id
    Environment = var.Environment
}