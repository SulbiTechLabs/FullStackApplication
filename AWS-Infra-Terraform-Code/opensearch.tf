# Minimal cost OpenSearch for testing
module "opensearch" {
  source  = "terraform-aws-modules/opensearch/aws"
  version = "~> 1.0"

  domain_name    = "test-opensearch"
  engine_version = "OpenSearch_2.11"

  cluster_config = {
    instance_type            = "t3.small.search"
    instance_count           = 1
    zone_awareness_enabled   = false
    dedicated_master_enabled = false
  }

  advanced_security_options = {
    enabled = false
  }

  auto_tune_options = {
    desired_state = "DISABLED"
  }

  ebs_options = {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = 10
  }

  encrypt_at_rest = {
    enabled = false
  }

  node_to_node_encryption = {
    enabled = false
  }

  domain_endpoint_options = {
    enforce_https = false
  }

  access_policy_statements = [
    {
      effect = "Allow"
      principals = [{
        type        = "AWS"
        identifiers = ["arn:aws:iam::${local.aws_account_id}:root"]
      }]
      actions = ["es:*"]
    }
  ]

  tags = {
    Environment    = var.environment
    Region         = var.tag_region
    Name           = "src-oss"
    CostCenter     = var.cost_center
    Contact        = var.contact
    Team           = var.team
    Project        = var.project
    Product        = var.product
    Component      = var.component
    Deploymenttype = var.deploymenttype
  }
}