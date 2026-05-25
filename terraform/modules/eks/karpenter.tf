resource "aws_iam_role" "karpenter_controller" {
  name = "KarpenterControllerRole-go-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity" # Command to AWS API if some object proofs that it is our Karpenter Controller, then AWS API will allow it to assume this role.
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/oidc.eks.${var.Region}.amazonaws.com/id/${var.oidc_id}"
      }
      Condition = {
        StringEquals = {
            # AWS API checks name of the object which is trying to assume this role, if it is name in JWT token matches with this field of JSON policy Role.
          "oidc.eks.${var.Region}.amazonaws.com/id/${var.oidc_id}:sub": "system:serviceaccount:karpenter:karpenter"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "karpenter_controller_allows" {
    name = "KarpenterAllowPolicy"
    role = aws_iam_role.karpenter_controller.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeAvailabilityZones",
          "ssm:GetParameter"
          ] 
          Effect = "Allow"
          Resource = "*"
        },
        {
          Action = "iam:PassRole"
          Effect = "Allow"
          Resource = aws_iam_role.karpenter_node.arn
        }
      ]
    })
}

