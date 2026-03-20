provider "azurerm" {
  features {
  }
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
  storage_use_azuread             = true
}
