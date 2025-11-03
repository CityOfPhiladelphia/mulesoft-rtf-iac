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

  env_name = "test"
  app_name = "rtf"
  # Non-prod vpc
  vpc_id = "vpc-0003c2fc508cbdab4"
  # Non-prod subnet private zone A then B
  eks_subnet_ids = ["subnet-0ff7f0642b438fbeb", "subnet-0d5478758a826841e"]
}
