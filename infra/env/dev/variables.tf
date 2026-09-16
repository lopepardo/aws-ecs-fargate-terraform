variable "container_image" {
  description = "Container image URI used by the ECS task."
  type        = string
}

variable "app_version" {
  description = "ID of the deployed app version"
  type        = string

  validation {
    condition     = length(trimspace(var.app_version)) > 0
    error_message = "app_version must not be empty."
  }
}
