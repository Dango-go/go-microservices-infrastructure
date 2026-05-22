variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "Environment" {
  type = string
}

variable "Project" {
  type = string
}