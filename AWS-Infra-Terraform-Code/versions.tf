# terraform {
#   required_version = ">= 1.3"

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 5.34"
#     }
#     helm = {
#       source  = "hashicorp/helm"
#       version = "2.11.0" # Explicitly set to stable version
#       #version = ">= 2.7"
#     }
#     kubectl = {
#       source  = "alekc/kubectl"
#       version = ">= 2.0"
#     }
#   }
# }

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34.0, < 6.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      #version = "2.11.0" # Explicitly set to stable version
      version = ">= 2.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}