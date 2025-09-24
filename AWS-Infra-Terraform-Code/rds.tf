# RDS PostgreSQL Instance
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier                 = "postgres-backend-db"
  engine                     = "postgres"
  engine_version             = "15.14"
  instance_class             = "db.t3.micro" # Free tier eligible
  allocated_storage          = 20
  db_name                    = "mydb"
  username                   = local.rds_creds.username
  password                   = local.rds_creds.password
  port                       = 5432
  family                     = "postgres15"
  major_engine_version       = "15"
  publicly_accessible        = false
  multi_az                   = false
  storage_type               = "gp2"
  vpc_security_group_ids     = [aws_security_group.rds.id]
  subnet_ids                 = module.vpc.private_subnets
  create_db_subnet_group     = true
  skip_final_snapshot        = true
  backup_retention_period    = 0
  auto_minor_version_upgrade = true

  tags = {
    Name           = "Postgres-${var.tag_region}-RDS"
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

# Security Group for RDS
resource "aws_security_group" "rds" {
  name   = "rds-postgres"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.all_worker_mgmt.id]
    description     = "Allow PostgreSQL from EKS nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres"
  }
}

# AWS Secrets Manager for RDS password
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds-postgres-password"
  description = "RDS PostgreSQL password"

  tags = {
    Name           = "RDS-Password-${var.tag_region}"
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

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = "postgresadmin"
    password = "changeme1234!SecurePass"
  })
}

data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id  = aws_secretsmanager_secret.rds_password.id
  depends_on = [aws_secretsmanager_secret_version.rds_password]
}

locals {
  rds_creds = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)
}
