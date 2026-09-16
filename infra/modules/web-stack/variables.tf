# General configuration
variable "name_prefix" {
  description = "Prefix used to name the resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (dev, staging, or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "app_version" {
  description = "ID of the deployed app version"
  type        = string
}

# Network configuration
variable "vpc_id" {
  description = "ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets used by the load balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets used by the ECS tasks."
  type        = list(string)
}

# ECS configuration
variable "task_cpu" {
  description = "CPU units allocated to each ECS task."
  type        = number
}

variable "task_memory" {
  description = "Memory in MiB allocated to each ECS task."
  type        = number
}

variable "container_image" {
  description = "Container image URI used by the ECS task."
  type        = string
}

variable "application_port" {
  description = "Port on which the application container listens."
  type        = number
  default     = 3000

  validation {
    condition     = var.application_port >= 1 && var.application_port <= 65535 && var.application_port == floor(var.application_port)
    error_message = "Application port must be an integer between 1 and 65535."
  }
}

variable "min_tasks" {
  description = "Minimum number of ECS tasks maintained by ECS Service Auto Scaling."
  type        = number
  nullable    = false

  validation {
    condition     = var.min_tasks >= 1 && var.min_tasks == floor(var.min_tasks)
    error_message = "The minimum number of ECS tasks must be at least one."
  }
}

variable "max_tasks" {
  description = "Maximum number of ECS tasks maintained by ECS Service Auto Scaling."
  type        = number
  nullable    = false

  validation {
    condition     = var.max_tasks >= 0 && var.max_tasks == floor(var.max_tasks)
    error_message = "Maximum ECS task count must be a non-negative integer."
  }

  validation {
    condition     = var.min_tasks <= var.max_tasks
    error_message = "Minimum ECS task count must be less than or equal to maximum ECS task count."
  }
}

variable "https" {
  description = "HTTPS and public DNS configuration. Null means HTTP-only."
  type = object({
    certificate_arn = string
    domain_name     = string
    route53_zone_id = string
    ssl_policy = optional(
      string,
      "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
    )
  })
  default = null

  validation {
    condition = var.https == null ? true : alltrue([
      length(trimspace(var.https.certificate_arn)) > 0,
      length(trimspace(var.https.domain_name)) > 0,
      length(trimspace(var.https.route53_zone_id)) > 0,
    ])
    error_message = "When https is configured, certificate_arn, domain_name, and route53_zone_id must not be empty."
  }
}
