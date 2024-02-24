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

  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  create_kms_key                           = true
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

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
      source_security_group_ids = [aws_security_group.remote_access.id]
      ami_type                  = "AL2_x86_64"
      instance_types            = ["t3.micro"]
      subnet_ids                = module.vpc.public_subnets
      min_size                  = 1
      max_size                  = 1
      desired_size              = 1
    }
  }

  tags = local.tags
}

resource "aws_security_group" "remote_access" {
  name_prefix = "${var.project-name}-remote-access"
  description = "Allow remote SSH access"
  vpc_id      = module.vpc.vpc_id

  # ingress {
  #   description = "SSH access"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "HTTPS access"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

resource "aws_iam_policy" "additional" {
  name = "eks-cluster-additional"

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
  tags = local.tags
}
