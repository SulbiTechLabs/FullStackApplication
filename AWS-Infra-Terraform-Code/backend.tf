#-----------------------------------------------------------------#
# Configure Terragrunt to automatically store tfstate files in S3 #
#-----------------------------------------------------------------#

# remote_state {
#   backend = "s3"

#   config = {
#     encrypt        = true
#     bucket         = "snwl-general-terraform-state"
#     key            = "mumbai/msw/eks/terraform.tfstate"
#     region         = "us-west-2"
#     dynamodb_table = "my-lock-table"
#    }
# }

# terraform {
#   backend "s3" {
#     encrypt      = true
#     bucket       = "us-east-1-terraform-state-12-02-25"
#     key          = "terraform.tfstate"
#     region       = "us-east-1"
#   }
# }
