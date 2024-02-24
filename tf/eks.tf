module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "${var.project-name}-cluster"
  cluster_version = var.cluster_version

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnets
  create_kms_key = true

  fargate_profiles = {
    example = {
      name = "${var.project-name}-profile"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
  }

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.micro"]
      subnet_ids     = module.vpc.public_subnets
      min_size       = 1
      max_size       = 1
      desired_size   = 1
    }
  }

  tags = local.tags
}

resource "aws_iam_policy" "additional" {
  name = "${var.project-name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
