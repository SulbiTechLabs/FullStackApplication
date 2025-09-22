#----------------------------------#
#Store the state file in S3 Bucket #
#----------------------------------#
# terraform {
#   # The configuration for this backend will be filled in by Terragrunt
#   backend "s3" {}
# }


#The Availability Zones data source allows access to the list of AWS Availability Zones which can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# data "kubernetes_service" "argocd_server" {
#   metadata {
#     name      = "argocd-server"
#     namespace = "argocd"
#   }
# }

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

#region VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"

  name = var.vpc_name

  cidr = "192.168.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = ["192.168.0.0/18", "192.168.64.0/18"]
  public_subnets  = ["192.168.128.0/18", "192.168.192.0/18"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true # Ensure public subnets auto-assign public IPs

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = "${var.cluster_name}"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = "${var.cluster_name}"
  }
}
#endregion VPC
#region Security Group
#Provides a security group resource for all nodes group
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = var.tcp_port
    to_port   = var.tcp_port
    protocol  = var.protocol

    cidr_blocks = var.cidr_blocks_all_worker_groups
  }
}

resource "aws_security_group" "all_worker_mgmt_one" {
  name_prefix = "all_worker_management_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1

    cidr_blocks = var.cidr_blocks_all_worker_groups
  }
}
#endregion

#region KMS
####KMS Key Creation for EKS Cluster Encryption######
module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  aliases               = ["eks/${var.cluster_name}"]
  description           = "${var.cluster_name} cluster encryption key"
  enable_default_policy = true
  key_owners            = [data.aws_caller_identity.current.arn]
  tags = {
    Environment    = var.environment
    Name           = var.cluster_name
    Region         = var.tag_region
    CostCenter     = var.cost_center
    Contact        = var.contact
    Team           = var.team
    Project        = var.project
    Product        = var.product
    Component      = var.component
    Deploymenttype = var.deploymenttype
  }
}
#endregion

#region EC2 key-pair
# Generate a new SSH key locally
resource "tls_private_key" "eks_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS Key Pair using the generated public key
resource "aws_key_pair" "eks_key" {
  key_name   = "cloudguru-key"
  public_key = tls_private_key.eks_key.public_key_openssh
}

# Save the private key locally (Important!)
resource "local_file" "private_key" {
  content         = tls_private_key.eks_key.private_key_pem
  filename        = "${path.module}/cloudguru-key.pem" # This saves the key in the same Terraform module directory
  file_permission = "0600"
}
#endregion EC2 key-pair

#region EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
  enable_cluster_creator_admin_permissions = true
  
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }
  
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  
  eks_managed_node_groups = {
    my_nodegroup = {
      name           = var.nodegroup_name
      instance_types = [var.instance_type]
      
      min_size     = var.asg_min_size_group
      max_size     = var.asg_max_size_group
      desired_size = var.asg_desired_capacity_group
      
      disk_size = var.disk_size
      
      tags = {
        Environment    = var.environment
        Region         = var.tag_region
        Name           = var.nodegroup_name
        CostCenter     = var.cost_center
        Contact        = var.contact
        Team           = var.team
        Project        = var.project
        Product        = var.product
        Component      = var.component
        Deploymenttype = var.deploymenttype
      }
    }
  }
  
  tags = {
    Environment    = var.environment
    Name           = var.cluster_name
    Region         = var.tag_region
    CostCenter     = var.cost_center
    Contact        = var.contact
    Team           = var.team
    Project        = var.project
    Product        = var.product
    Component      = var.component
    Deploymenttype = var.deploymenttype
  }
}
# module "aws_auth" {
#   source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
#   version = "20.35.0"
#   manage_aws_auth_configmap = true
#   #eks_cluster_name = module.eks.eks_cluster_id

#   aws_auth_accounts = [local.aws_account_id]

#   aws_auth_roles = [
#     {
#       rolearn  = "arn:aws:iam::${local.aws_account_id}:role/role1"
#       username = "role1"
#       groups   = ["system:masters"]
#     },
#   ]

#   aws_auth_users = [
#     {
#       userarn  = "arn:aws:iam::${local.aws_account_id}:user/cloud_user"
#       username = "cloud_user"
#       groups   = ["system:masters"]
#     },
#   ]
# }

#endregion





#region EBS CSI IRSA Role (correct v5.34.0+ syntax)
module "ebs_csi_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name             = "AmazonEKS_EBS_CSI_DriverRole_${var.component}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Name           = "AmazonEKS_EBS_CSI_DriverRole_${var.component}"
    Environment    = var.environment
    Region         = var.tag_region
    CostCenter     = var.cost_center
    Contact        = var.contact
    Team           = var.team
    Project        = var.project
    Product        = var.product
    Component      = var.component
    Deploymenttype = var.deploymenttype
  }
}
#endregion

#region ALB Controller IRSA Role (correct v5.34.0+ syntax)
module "lb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name                              = "AmazonEKSLoadBalancerControllerRole-${var.tag_region}-myproj"
  attach_load_balancer_controller_policy = true
  
  # Additional policies for missing permissions
  role_policy_arns = {
    additional = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Name           = "AmazonEKSLoadBalancerControllerRole-${var.tag_region}-myproj"
    Environment    = var.environment
    Region         = var.tag_region
    CostCenter     = var.cost_center
    Contact        = var.contact
    Team           = var.team
    Project        = var.project
    Product        = var.product
    Component      = var.component
    Deploymenttype = var.deploymenttype
  }
}
#endregion
#Kubernetes resources temporarily disabled during cluster recreation
resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "alb-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  timeout    = 600
  wait       = true
  depends_on = [
    kubernetes_service_account.service-account,
    module.eks.eks_managed_node_groups
  ]

  set = [
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = module.vpc.vpc_id
    },
    {
      name  = "image.repository"
      value = "public.ecr.aws/eks/aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "clusterName"
      value = var.cluster_name
    }
  ]
}
#endregion

#region ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 600
  wait             = true
  depends_on = [
    module.eks.eks_managed_node_groups
  ]

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
EOF
  ]
}
#endregion
