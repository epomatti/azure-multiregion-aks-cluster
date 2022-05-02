### General

variable "application_name" {
  type        = string
  description = "The application name is used for composition of all the resouces in the solution."
  default     = "openvote555dev"

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.application_name))
    error_message = "Application name must be composed by integers and lower-case letters only."
  }
}

variable "main_location" {
  type        = string
  description = "The Location of the main site."
  default     = "westus"
}

### Cosmos

variable "cosmos_enable_free_tier" {
  type        = bool
  description = "Enable Cosmos Free tier"
  default     = true
}
