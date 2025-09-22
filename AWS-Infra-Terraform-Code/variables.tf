variable "cluster_name" {
  description = "Cluster Name"
}

variable "tcp_port" {
  description = "tcp port"
}

variable "protocol" {
  description = "protocol"
}

variable "vpc_name" {
  
}
# variable "vpc_id" {
#   description = "ID of VPC"
# }

# variable "vpc_private_subnets" {
#   description = "VPC private cidr blocks"
#   type        = list(string)
# }

variable "cluster_version" {
  description = "Kubernetes cluster version"
}

variable "log_types" {
  description = "Log types"
  type        = list(string)
}

variable "instance_type" {}


variable "cidr_blocks_all_worker_groups" {
  type = list(string)
}


# variable "ssh_key" {
#   description = "ssh_key"
# }

variable "environment" {
  description = "environment(prod, prodsim, dev etc)"
}

variable "tag_region" {
  description = "region of deployment"
}


# variable "applicationtype" {
#   description = "applicationtype"
# }


# variable "bu" {
#   description = "Bussiness Unit"
# }

variable "nodegroup_name" {
  description = "Nodegroup Name"
}

variable "asg_desired_capacity_group" {}

variable "asg_max_size_group" {}

variable "asg_min_size_group" {}

variable "iam_role_use_name_prefix" {
  type        = bool
  default     = "false"
  description = "description"
}

variable "region" {}

variable "disk_size" {}

# variable "map_accounts" {
#   description = "Additional AWS account numbers to add to the aws-auth configmap."
#   type        = list(string)
# }

# variable "map_roles" {
#   description = "Additional IAM roles to add to the aws-auth configmap."
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))
# }

# variable "map_users" {
#   description = "Additional IAM users to add to the aws-auth configmap."
#   type = list(object({
#     userarn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#     {
#       userarn  = "arn:aws:iam::281687379045:user/ynatarajan"
#       username = "ynatarajan"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::281687379045:user/btkubendran"
#       username = "btkubendran"
#       groups   = ["system:masters"]
#     },
#   ]
# }

# variable "bussiness_unit" {
#   type = string
# }

variable "cost_center" {
  type = string
}

variable "contact" {
  type = string
}

variable "team" {
  type = string
}

variable "project" {
  type = string
}

variable "product" {
  type = string
}

variable "component" {
  type = string
}

variable "deploymenttype" {
  type = string
}

