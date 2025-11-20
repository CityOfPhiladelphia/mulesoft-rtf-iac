#locals {
#  default_tags = {
#    ManagedBy   = "Terraform"
#    Application = var.app_name
#    TfEnv       = var.env_name
#  }
#}

# Continue using builtin AWS key for now
data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}
