locals {
  tags = {
    Terraform = "true"
    Project   = "Kubernetes Cloud Resume"
  }
  aws_region = var.aws_region
}