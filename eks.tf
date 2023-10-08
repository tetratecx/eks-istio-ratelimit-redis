module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.17.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = "1.27"

  cluster_endpoint_private_access = var.eks_cluster_endpoint_public_access
  cluster_endpoint_public_access  = var.eks_cluster_endpoint_public_access

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    disk_size = 30
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.micro"]
      capacity_type  = "ON_DEMAND"
    }

    spot = {
      desired_size = 1
      min_size     = 1
      max_size     = 10

      labels = {
        role = "dev"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "spot"
          effect = "NO_SCHEDULE"
        }
      }
      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"
    }
  }

  tags = var.eks_tags
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.id]
    command     = "aws"
  }
}