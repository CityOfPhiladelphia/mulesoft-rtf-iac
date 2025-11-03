locals {
  default_tags = {
    ManagedBy   = "Terraform"
    Application = var.app_name
    TfEnv       = var.env_name
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Continue using builtin AWS key for now
data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

// Shared-GSG -> Github -> Keepercfg
data "secretsmanager_login" "keeper" {
  path = "l4pqeAaAA7HGzEXaNdKVWQ"
}

