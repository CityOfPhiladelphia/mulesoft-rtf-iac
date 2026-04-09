// Continue using builtin AWS key for now
data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

// Shared-GSG -> Mulesoft -> RTF Keeper Key
data "secretsmanager_login" "keeper" {
  path = "VJGhv311blHgWCPTtoGJnw"
}
