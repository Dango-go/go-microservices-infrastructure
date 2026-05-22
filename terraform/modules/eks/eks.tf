locals {
  cluster_name = "astronomy-shop-dev"
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

  cluster_addons = {
    coredns = { addon_version = "v1.11.3-eksbuild.1"}
    vpc_cni = { addon_version = "v1.18.5-eksbuild.1" }
    kube_proxy = { addon_version = "v1.31.0-eksbuild.1" }
    aws-ebs-csi-driver = { addon_version = "v1.35.0-eksbuild.1" }
  }

  tags = {
    Node = "Cluster"
    
  }  

  # Worker Nodes
  eks_managed_node_groups = {
    main = {
      ami_type = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.medium"]
      min_size     = 1
      max_size     = 3
      desired_size = 1


      
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