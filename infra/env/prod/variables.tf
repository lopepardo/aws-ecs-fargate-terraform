variable "container_image" {
  description = "Container image URI used by the ECS task."
  type        = string

  validation {
    condition = can(
      regex("@sha256:[0-9a-fA-F]{64}$", var.container_image)
    )
    error_message = "container_image must end with a SHA-256 digest."
  }
}

variable "app_version" {
  description = "ID of the deployed app version"
  type        = string

  validation {
    condition     = length(trimspace(var.app_version)) > 0
    error_message = "app_version must not be empty."
  }
}

variable "certificate_arn" {
  description = "value"
  type        = string
}

variable "domain_name" {
  description = "value"
  type        = string
}

variable "route53_zone_id" {
  description = "value"
  type        = string
}