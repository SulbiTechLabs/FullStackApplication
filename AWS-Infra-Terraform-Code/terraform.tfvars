#Region for the VPC
region = "us-east-1"

tcp_port = 22
protocol = "tcp"

vpc_name = "eks-cluster-vpc"
#vpc_id = "vpc-0037c5392bfa79172"

## Change the CIDR to match the environments
cidr_blocks_all_worker_groups = ["192.168.0.0/16"]
## Private subnets of the VPV
#vpc_private_subnets = ["subnet-02840ffbc2cadf5da", "subnet-0d616b25850118cd6"]

cluster_name    = "src-eks-cluster"
cluster_version = "1.32"

log_types = ["api", "audit", "scheduler"]

disk_size                  = 15
nodegroup_name             = "mynode-group"
instance_type              = "t3a.medium"
asg_desired_capacity_group = 2
asg_max_size_group         = 2
asg_min_size_group         = 2

#Tags
environment    = "DEV"
tag_region     = "use1"
cost_center    = "ABCD"
contact        = "src@gmail.com"
team           = "DevOps"
project        = "EKS"
product        = "New Product"
component      = "DevOps"
deploymenttype = "Terraform"

#ssh_key = "cloudguru-key"

#aws_account_id = "471112559300"
#map_accounts = [aws_account_id]
# map_accounts = [data.aws_caller_identity.current.account_id]

# map_roles = [
#   {
#     rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/role1"
#     username = "role1"
#     groups   = ["system:masters"]
#   },
# ]

# map_users = [
#   {
#     userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/cloud_user"
#     username = "cloud_user"
#     groups   = ["system:masters"]
#   },
# ]
