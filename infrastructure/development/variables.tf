### General

variable "application_name" {
  type        = string
  description = "The application name is used for composition of all the resouces in the solution."
  default     = "voteapp789"

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.application_name))
    error_message = "Application name must be composed by integers and lower-case letters only."
  }
}

variable "location" {
  type        = string
  description = "The location of the infrastructure."
  default     = "westus"
}

variable "environment" {
  type        = string
  description = "The keyword to identify te type of environment that it's being deployed."
  default     = "dev"
}

variable "instance" {
  type        = string
  description = "Instance code to be added to the resources."
  default     = "001"
}
