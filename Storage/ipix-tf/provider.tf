provider "azurerm" {
  features {
  }
  subscription_id                 = var.subscription_id
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}
