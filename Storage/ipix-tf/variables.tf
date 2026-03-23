# $env:ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-00000000"

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "swedencentral" #az account list-locations --query "sort_by([].{FriendlyName:displayName, Name:name}, &Name)" -o table
}

variable "suffix" {
  description = "Unique suffix appended to resource names"
  type        = string
  default     = "abc123" #neptun code
}

variable "enable_ai_foundry" {
  description = "If true, create an Azure AI Foundry (AI Services) resource and attach it to the skillset for billing"
  type        = bool
  default     = false
}


