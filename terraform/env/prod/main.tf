terraform {
  required_version = "~> 1.12"

  #cloud {
  #  organization = "Philadelphia"

  #  workspaces {
  #    name = "mulesoft-flex-gateway-test"
  #  }
  #}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    secretsmanager = {
      source  = "keeper-security/secretsmanager"
      version = ">= 1.1.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
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
}
