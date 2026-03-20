variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "swedencentral"
}

variable "suffix" {
  description = "Unique suffix appended to resource names"
  type        = string
  default     = "abc123" #neptun code
}

variable "subscription_id" {
  description = "Azure subscription ID — overridable via TF_VAR_subscription_id or ARM_SUBSCRIPTION_ID"
  type        = string
  default     = "00000000-00000000-00000000"
}
