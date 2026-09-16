data "aws_region" "current" {}

locals {
  container_name  = "app"
  aws_region      = data.aws_region.current.region
  https_enabled   = var.https != null
  https_resources = var.https == null ? {} : { https = var.https }
}
