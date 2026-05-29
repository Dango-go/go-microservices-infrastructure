locals {
  cluster_name = "go-cluster-${var.Environment}"
  region       = "eu-central-1"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  
  cluster_version = "1.31"

  cluster_endpoint_public_access = true
 
  authentication_mode = "API_AND_CONFIG_MAP"
 
  enable_cluster_creator_admin_permissions = true
  
  enable_irsa = true

  cluster_addons = {}

  tags = {
    Node = "Cluster"
    
  }  

  # Worker Nodes
  eks_managed_node_groups = {
    main = {
      ami_type = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]
      min_size     = 2
      max_size     = 3
      desired_size = 2


      
      associate_public_ip_address = true # For public subnets, set to true to allow nodes to have public IPs for direct internet access. For private subnets, set to false and ensure proper NAT gateway configuration for outbound internet access.
      
       
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 20
            volume_type = "gp3"
          }
        }

          tags = {
            Environment = var.Environment
            Project     = var.Project
            Node = "Worker"
          }
      }
    }
  }

  # Security group rules for worker nodes
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_api = {
      description                   = "Cluster CPU to node ports"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true # Allow traffic only from the cluster security group
    }
  }
}

module "ebs_csi_irsa_driver" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  role_name = "ebs-csi-driver-go-cluster"
  
  attach_ebs_csi_policy = true
  
  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = module.eks.cluster_name
  addon_name   = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_irsa_driver.iam_role_arn
}

resource "aws_ecr_repository" "go_services" {
  for_each = toset(["go-auth-service", "go-order-service", "go-product-service", "go-gtw-service"])
  name = each.key
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true 
  }

  tags = {
    Enviroment = var.Environment
    Project    = var.Project
  }
}