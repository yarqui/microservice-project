terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "yar-tfstate-8921"
  table_name  = "terraform-locks"
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr_block       = "10.0.0.0/16"
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name             = "lesson-9-vpc"
}

module "ecr" {
  source   = "./modules/ecr"
  ecr_name = "lesson-9-django-app"
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "lesson-9-cluster"
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  public_subnets  = module.vpc.public_subnet_ids
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.40.0"

  role_name_prefix      = "EBS_CSI_Driver_Role"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name           = module.eks.cluster_name
  addon_name             = "aws-ebs-csi-driver"
  resolve_conflicts_on_create        = "OVERWRITE"
  service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  github_user     = var.github_user
  github_pat      = var.github_pat
  github_repo_url = var.github_repo_url
  ecr_repo_url    = module.ecr.repository_url

  depends_on = [
    aws_eks_addon.ebs_csi_driver
  ]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}