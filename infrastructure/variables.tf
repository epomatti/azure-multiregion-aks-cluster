variable "application_name" {
  type        = string
  description = "The application name is used for composition of all the resouces in the solution."
  default     = "openvote555"

  validation {
    condition     = can(regex("^[[:alnum:]]+$", var.application_name))
    error_message = "Application name must be composed by integers and lower-case letters only."
  }
}
