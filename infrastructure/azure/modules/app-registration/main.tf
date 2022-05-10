resource "azuread_application" "default" {
  display_name            = "aks-service-principal-${var.root_name}"
  group_membership_claims = []
  identifier_uris         = []
  owners                  = []
}

resource "azuread_application_federated_identity_credential" "default" {
  application_object_id = azuread_application.default.object_id
  display_name          = "kubernetes-federated-credential"
  description           = "Kubernetes service account federated credential"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = var.oidc_issuer_url
  subject               = "system:serviceaccount:${var.aks_namespace}:${var.service_account_name}"
}

resource "azuread_service_principal" "default" {
  application_id               = azuread_application.default.application_id
  app_role_assignment_required = false
  alternative_names            = []
  notification_email_addresses = []
  owners                       = []
}
