resource  "aws_sqs_queue" "karpenter" {
    name = "go-cluster-dev-karpenter-queue"
    message_retention_seconds = 300
}