### General

variable "main_location" {
  type        = string
  description = "The location of the Main site."
  default     = "westus3"
}

variable "failover_location" {
  type        = string
  description = "The location of the Failover site."
  default     = "canadaeast"
}

variable "environment" {
  type        = string
  description = "The keyword to identify te type of Environment that it's being deployed."
  default     = "prod"
}

variable "main_instance" {
  type        = string
  description = "Instance code to be added to Main resources."
  default     = "001"
}

variable "failover_instance" {
  type        = string
  description = "Instance code to be added to Failover resources."
  default     = "002"
}

variable "jumbbox_vm_password" {
  type        = string
  description = "The password to connect to the Jumpbox VM"
  default     = "P@ssw0rd.123"
  sensitive   = true
}
