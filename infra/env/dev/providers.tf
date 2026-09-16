terraform {
  required_version = ">= 1.10, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = local.aws_region

  # assume_role {
  #   role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformDeployRole"
  # }

  default_tags {
    tags = local.tags
  }
}