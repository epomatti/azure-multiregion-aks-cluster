variable "app_root" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "nsg_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
