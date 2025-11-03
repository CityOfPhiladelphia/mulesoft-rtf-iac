// Continue using builtin AWS key for now
data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

// Shared-GSG -> Github -> Keepercfg
data "secretsmanager_login" "keeper" {
  path = "l4pqeAaAA7HGzEXaNdKVWQ"
}
