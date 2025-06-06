provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

provider "random" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_rds_engine_version" "default" {
  engine = var.db_engine
}

data "aws_rds_orderable_db_instance" "this" {
  engine                     = data.aws_rds_engine_version.default.engine
  storage_type               = var.db_storage_type
  preferred_instance_classes = [var.db_instance_class]
}

locals {
  azs     = var.zones != null ? var.zones : data.aws_availability_zones.available.names
  db_name = lower(replace(var.project_name, " ", ""))
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.0"
  name               = replace(var.project_name, " ", "-")
  cidr               = var.cidr
  azs                = slice(local.azs, 0, 3)
  enable_nat_gateway = true
  private_subnets    = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k)]
  public_subnets     = [for k, v in local.azs : cidrsubnet(var.cidr, 5, k + length(local.azs))]
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "rds" {
  source               = "terraform-aws-modules/rds/aws"
  version              = "~> 5.0"
  identifier           = "${local.db_name}-db"
  engine               = data.aws_rds_orderable_db_instance.this.engine
  # engine_version       = data.aws_rds_orderable_db_instance.this.engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.db_allocated_storage
  storage_type         = var.db_storage_type
  username             = local.db_name
  password             = random_password.db_password.result
  # family = data.aws_rds_engine_version.default.fami
  family               = "postgres17"
  # major_engine_version = data.aws_rds_orderable_db_instance.this.engine_latest_version
  db_subnet_group_name = module.vpc.database_subnet_group
}
