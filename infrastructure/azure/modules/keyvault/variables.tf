variable "root_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "jumpbox_subnet_id" {
  type = string
}

variable "backup_jumpbox_subnet_id" {
  type = string
}

variable "aks_service_principal_object_id" {
  type = string
}

variable "cosmos_connection_string" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}
