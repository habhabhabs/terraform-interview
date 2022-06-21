variable "subscription_id" {
  description = "(to define in tfvars) Subscription ID to register RG to current Terraform execution."
  type        = string
}

variable "container_version_num" {
  description = "two options: only 1.0 or 2.0"
  type        = string
}