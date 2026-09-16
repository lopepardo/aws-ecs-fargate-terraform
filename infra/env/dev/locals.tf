locals {
  # General
  project_name = "ecs-alb"
  environment  = "dev"
  name_prefix  = "${local.project_name}-${local.environment}"
  aws_region   = "us-east-1"
  tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  # Networking
  vpc_cidr = "10.20.0.0/16"
  availability_zones = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]
  subnets = {
    az-a = {
      az           = local.availability_zones[0]
      public_cidr  = cidrsubnet(local.vpc_cidr, 8, 0)
      private_cidr = cidrsubnet(local.vpc_cidr, 8, 10)
    }
    az-b = {
      az           = local.availability_zones[1]
      public_cidr  = cidrsubnet(local.vpc_cidr, 8, 1)
      private_cidr = cidrsubnet(local.vpc_cidr, 8, 11)
    }
  }
}