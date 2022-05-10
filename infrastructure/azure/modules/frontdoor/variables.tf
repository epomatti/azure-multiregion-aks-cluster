variable "root_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "main_ingress_address" {
  type = string
}

variable "failover_ingress_address" {
  type = string
}

variable "tags" {
  type = map(string)
}
