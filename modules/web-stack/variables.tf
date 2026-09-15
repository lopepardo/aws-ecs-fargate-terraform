# General configuration
variable "name_prefix" {
  description = "Prefix used to name the resources."
  type        = string
}

variable "aws_region" {
  description = "AWS Region where resources are deployed."
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

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
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

  # validation {
  #   condition = can(
  #     regex("@sha256:[0-9a-fA-F]{64}$", var.container_image)
  #   )
  #   error_message = "container_image must end with a SHA-256 digest."
  # }
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
    condition     = var.min_tasks >= 0 && var.min_tasks == floor(var.min_tasks)
    error_message = "Minimum ECS task count must be a non-negative integer."
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
