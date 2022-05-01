variable "application_name" {
  type        = string
  description = "The application name is used for composition of all the resouces in the solution."
  default     = "openvote555"

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.application_name))
    error_message = "Application name must be composed by integers and lower-case letters only."
  }
}

variable "main_location" {
  type        = string
  description = "The Location of the main site."
  default     = "eastus2"
}

variable "failover_location" {
  type        = string
  description = "The Location of the failover site."
  default     = "westus"
}

variable "aks_vm_size" {
  description = "Kubernetes VM size"
  type        = string
  default     = "Standard_B2s"
}
