variable "application_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "main_location" {
  type = string
}

# variable "failover_location" {
#   type = string
# }

variable "enable_free_tier" {
  type    = bool
  default = true
}

variable "total_throughput_limit" {
  type    = number
  default = 1000
}
