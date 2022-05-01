variable "application_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_principal_id" {
  type = string
}

variable "cosmos_connection_string" {
  type      = string
  sensitive = true
}
