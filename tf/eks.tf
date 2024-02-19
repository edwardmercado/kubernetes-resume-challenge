module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                   = "${var.project-name}-cluster"
  cluster_version                = var.cluster_version

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

#   # Fargate profiles use the cluster primary security group so these are not utilized
#   create_cluster_security_group = false
#   create_node_security_group    = false

  tags = local.tags
}
