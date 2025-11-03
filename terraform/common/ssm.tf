resource "aws_ssm_parameter" "keeper_cfg" {
  name   = "/rtf/keeper_cfg"
  value  = data.secretsmanager_login.keeper.password
  type   = "SecureString"
  key_id = data.aws_kms_alias.ssm.arn
}
