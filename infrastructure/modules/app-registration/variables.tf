variable "environment" {
  type    = string
  default = "prod"
}

variable "oidc_issuer_url" {
  type = string
}

variable "aks_namespace" {
  type = string
}

variable "service_account_name" {
  type = string
}
