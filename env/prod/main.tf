module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${local.name_prefix}-vpc"
  cidr = local.vpc_cidr

  azs = local.availability_zones

  public_subnets  = [for subnet in local.subnets : subnet.public_cidr]
  private_subnets = [for subnet in local.subnets : subnet.private_cidr]

  enable_dns_support   = true
  enable_dns_hostnames = true

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  map_public_ip_on_launch = false

  manage_default_security_group = true
  # default_network_acl_ingress   = []
  default_security_group_egress = []

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "web application"
  }

  tags = local.tags
}

module "web_stack" {
  source = "../../modules/web-stack"

  name_prefix = local.name_prefix
  aws_region  = local.aws_region
  environment = local.environment
  tags        = local.tags

  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnets
  private_subnet_ids = module.network.private_subnets

  container_image  = var.container_image
  task_cpu         = 256
  task_memory      = 512
  application_port = 80
  min_tasks        = 4
  max_tasks        = 8
}