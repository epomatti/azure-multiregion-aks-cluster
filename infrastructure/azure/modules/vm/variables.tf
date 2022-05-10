variable "workload_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
}
