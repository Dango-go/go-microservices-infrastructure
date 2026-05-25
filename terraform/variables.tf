variable "Environment" {
  type = string
}

variable "Project" {
  type = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "oidc_id" {
  description = "OIDC ID for EKS cluster"
  type        = string
}

variable "Region" {
  description = "AWS region"
  type        = string
}