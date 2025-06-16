variable "app_name" {
  description = "A unique name for your application."
  type        = string
}

variable "gitlab_trigger_token" {
  description = "The trigger token for the VM creation pipeline."
  type        = string
  sensitive   = true
}

variable "gitlab_project_id" {
  description = "The project ID for the VM creation pipeline."
  type        = string
}