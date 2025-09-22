# module "opensearch" {
#   source = "terraform-aws-modules/opensearch/aws"


#   # Domain
#   advanced_options = {
#     "rest.action.multi.allow_explicit_index" = "true"
#   }

#   advanced_security_options = {
#     enabled                        = false
#     anonymous_auth_enabled         = true
#     internal_user_database_enabled = true

#     master_user_options = {
#       master_user_name     = "example"
#       master_user_password = "Barbarbarbar1!"
#     }
#   }

#   auto_tune_options = {
#     desired_state = "DISABLED"

#     maintenance_schedule = [
#       {
#         start_at                       = "2028-05-13T07:44:12Z"
#         cron_expression_for_recurrence = "cron(0 0 ? * 1 *)"
#         duration = {
#           value = "2"
#           unit  = "HOURS"
#         }
#       }
#     ]

#     rollback_on_disable = "NO_ROLLBACK"
#   }

#   cluster_config = {
#     instance_count           = 1
#     dedicated_master_enabled = false
#     #dedicated_master_type    = "t3.medium.search"
#     instance_type = "t3.medium.search"

#     # zone_awareness_config = {
#     #   availability_zone_count = 1
#     # }

#     zone_awareness_enabled = false
#   }

#   domain_endpoint_options = {
#     enforce_https       = true
#     tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
#   }

#   domain_name = "src-oss"

#   ebs_options = {
#     ebs_enabled = true
#     iops        = 3000
#     throughput  = 125
#     volume_type = "gp3"
#     volume_size = 10
#   }

#   encrypt_at_rest = {
#     enabled = true
#   }

#   engine_version = "OpenSearch_2.11"

#   log_publishing_options = [
#     { log_type = "INDEX_SLOW_LOGS" },
#     { log_type = "SEARCH_SLOW_LOGS" },
#   ]

#   node_to_node_encryption = {
#     enabled = true
#   }

#   software_update_options = {
#     auto_software_update_enabled = true
#   }

#   #   vpc_options = {
#   #     subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
#   #   }

#   # VPC endpoint
#   #   vpc_endpoints = {
#   #     one = {
#   #       subnet_ids = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
#   #     }
#   #   }

#   # Access policy
#   access_policy_statements = [
#     {
#       effect = "Allow"

#       principals = [{
#         type        = "*"
#         identifiers = ["*"]
#       }]

#       actions = ["es:*"]

#       conditions = [{
#         test     = "IpAddress"
#         variable = "aws:SourceIp"
#         values   = ["103.5.133.173/32"]
#       }]
#     },
#     {
#       effect = "Allow"

#       principals = [{
#         type        = "AWS"
#         identifiers = ["arn:aws:iam::${local.aws_account_id}:role/mynode-group-eks-node-group"]
#       }]

#       actions = ["es:*"]
#     }
#   ]

#   tags = {
#     Environment    = var.environment
#     Region         = var.tag_region
#     Name           = "src-oss"
#     CostCenter     = var.cost_center
#     Contact        = var.contact
#     Team           = var.team
#     Project        = var.project
#     Product        = var.product
#     Component      = var.component
#     Deploymenttype = var.deploymenttype
#   }
# }
