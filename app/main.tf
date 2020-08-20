provider "aws" {
  region = var.region
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-dev-application"
    key    = "dev/us-east-1/landing-zone"
    region = "us-east-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.my-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}

#module "my-cluster" {
#  source                    = "../eks"
#  cluster_name              = var.cluster_name
#  cluster_version           = "1.16"
#  subnets                   = data.terraform_remote_state.network.outputs.private_subnet_id
#  vpc_id                    = data.terraform_remote_state.network.outputs.vpc_id
#  bastion_security_group_id = data.terraform_remote_state.network.outputs.bastion_sg_id
#  worker_groups = [
#   {
#     instance_type                 = "t2.small"
#     asg_desired_capacity          = 1
#   },
#   {
#     instance_type                 = "t2.medium"
#     asg_desired_capacity          = 1
#   },
# ]
#}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_version                    = var.cluster_version
  cluster_name                       = var.cluster_name
  subnets                            = data.terraform_remote_state.network.outputs.private_subnet_id
  vpc_id                             = data.terraform_remote_state.network.outputs.vpc_id
  cluster_endpoint_private_access    = var.private_endpoint
  cluster_endpoint_public_access     = var.public_endpoint

  worker_groups_launch_template = [
    {
      name                 = "worker-group-1"
      instance_type        = var.instance_type
      autoscaling_enabled  = true
      asg_desired_capacity = var.asg_desired
      asg_min_size         = var.asg_min
      asg_max_size         = var.asg_max
      key_name             = var.key_pair
      root_encrypted       = true
      root_kms_key_id      = var.kms_key_id
      enabled_metrics      = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity"]
    },
  ]

  tags = local.tags
}
