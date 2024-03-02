module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "${var.project-name}-cluster"
  cluster_version = var.cluster_version

  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    coredns = {
      most_recent = true
    }
  }

  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.public_subnets
  create_kms_key                           = true
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  eks_managed_node_groups = {
    default = {
      source_security_group_ids = [aws_security_group.node_group_security_group.id]
      ami_type                  = "AL2_x86_64"
      instance_types            = ["t3.medium"]
      subnet_ids                = module.vpc.public_subnets
      min_size                  = 1
      max_size                  = 1
      desired_size              = 1
      disk_size = 50
    }
  }

  tags = local.tags
}

resource "aws_security_group" "node_group_security_group" {
  name_prefix = "${var.project-name}-node-group"
  description = "Allow remote SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "DB access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

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
