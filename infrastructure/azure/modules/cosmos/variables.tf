variable "root_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "main_location" {
  type = string
}

variable "failover_location" {
  type = string
}

variable "aks_main_subnet_id" {
  type = string
}

variable "aks_failover_subnet_id" {
  type = string
}

variable "jumpbox_main_subnet_id" {
  type = string
}

variable "jumpbox_failover_subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
