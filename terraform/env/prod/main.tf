terraform {
  required_version = "~> 1.12"

  backend "s3" {
    bucket = "phl-citygeo-terraform-state"
    # CHANGE ME!
    key          = "rtf/prod"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.21.0"
    }
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = "1.1.7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::975050025792:role/TFRole"
    session_name = "tf"
  }
}

provider "secretsmanager" {
}

module "app" {
  source = "../../modules/app"

  env_name = "prod"
  app_name = "rtf"
  # Prod vpc
  vpc_id = "vpc-047bfd23682f9582f"
  # Prod subnet private zone A then B
  eks_subnet_ids = ["subnet-00eb4cfd73abefd2e", "subnet-0d0d5a4bdbaf916d1"]
  eks_admins_iam_arns = [
    # SSO roles
    "arn:aws:iam::975050025792:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWS-mulesoft-infra-admins_a23294be18f9f843",
    "arn:aws:iam::975050025792:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWS-mulesoft-infra-devs_128f50c8d80a23d4",
    # Terraform role
    "arn:aws:iam::975050025792:role/TFRole"
  ]
}
