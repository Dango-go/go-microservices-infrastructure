resource "aws_security_group" "vps_sg" {
  name        = "vps-security-group"
  description = "Security group for VPS security"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Your Public IP but if you choose Bottlerocket OS you can remove this rule
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Security Group for VPS"
    Environment = var.Environment
  }
}