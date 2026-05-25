# Create IAM Role for Karpenter Nodes
resource "aws_iam_role" "karpenter_node" {
  name = "KarpenterNodeRole-go-cluster-dev"
  
  # Trust Policy for EC2 to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      # Action and Effect for allowing EC2 to assume this role
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}
# Policy: login to cluster, get connect with cluster API.
resource "aws_iam_role_policy_attachment" "node_policy_1" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Policy: connect to AWS VPC API, manage ENI.
resource "aws_iam_role_policy_attachment" "node_policy_2" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Create Instance Profile for attaching to IAM Role to instances
resource "aws_iam_instance_profile" "karpenter_node" {
  name = "KarpenterNodeInstanceProfile-go-cluster-dev"
  role = aws_iam_role.karpenter_node.name
}


