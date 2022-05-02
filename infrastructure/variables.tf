### General

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
  default     = "westus"
}

variable "failover_location" {
  type        = string
  description = "The Location of the failover site."
  default     = "canadaeast"
}

variable "environment" {
  type        = string
  default     = "prod"
}

### Cosmos

variable "cosmos_enable_free_tier" {
  type        = bool
  description = "Enable Cosmos Free tier"
  default     = true
}

variable "cosmos_total_throughput_limit" {
  type    = number
  default = 1000
}

### AKS

variable "aks_vm_size" {
  description = "Kubernetes VM size"
  type        = string
  default     = "Standard_B2s"
}

variable "aks_ingress_subnet_cidr" {
  description = "Application Gateway Ingress IP Range"
  type        = string
  default     = "10.225.0.0/16"
}
