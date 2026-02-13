terraform {
  required_version = "~> 1.12"

  backend "s3" {
    bucket = "phl-citygeo-terraform-state"
    # CHANGE ME!
    key          = "rtf/test"
    region       = "us-east-1"
    use_lockfile = true
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
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

  app_name = "rtf"
  env_name = "test"

  # Non-prod vpc
  vpc_id = "vpc-0003c2fc508cbdab4"
  # Non-prod subnet private zone A then B
  eks_subnet_ids = ["subnet-0ff7f0642b438fbeb", "subnet-0d5478758a826841e"]
  # IAM Roles to add to EKS Admin
  eks_admins_iam_arns = [
    # SSO roles
    "arn:aws:iam::975050025792:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWS-mulesoft-infra-admins_a23294be18f9f843",
    "arn:aws:iam::975050025792:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWS-mulesoft-infra-devs_128f50c8d80a23d4",
    # Terraform role
    "arn:aws:iam::975050025792:role/TFRole"
  ]
}
