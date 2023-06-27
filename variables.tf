variable "azurerm_provider_subscription_id" {
  type        = string
  description = "The Azure subscription ID"
  default     = ""
}

variable "host_name" {
  type        = string
  description = "Domain name of OpenCTI"
  default     = ""
}

variable "deploy_opencti_connector" {
  type        = bool
  description = "Should the OpenCTI connector be deployed?"
  default     = true
}