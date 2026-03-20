data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "ipix" {
  location = var.location
  name     = "ipix2026"
}
resource "azurerm_search_service" "ipix" {
  local_authentication_enabled = false
  location                     = var.location
  name                         = "ipixidx${var.suffix}"
  resource_group_name          = azurerm_resource_group.ipix.name
  sku                          = "free"
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_role_assignment" "admin_search_index_reader" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Search Index Data Reader"
  scope                = azurerm_search_service.ipix.id
}
resource "azurerm_storage_account" "ipix" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  default_to_oauth_authentication = true
  shared_access_key_enabled       = false
  location                        = var.location
  name                            = "ipixblobs${var.suffix}"
  resource_group_name             = azurerm_resource_group.ipix.name
}
resource "azurerm_storage_container" "photos" {
  name               = "photos"
  storage_account_id = azurerm_storage_account.ipix.id
}
resource "azurerm_storage_container" "thumbnails" {
  name               = "thumbnails"
  storage_account_id = azurerm_storage_account.ipix.id
}
resource "azurerm_role_assignment" "admin_blob_contributor" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.ipix.id
}
resource "azurerm_role_assignment" "search_blob_reader" {
  principal_id         = azurerm_search_service.ipix.identity[0].principal_id
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_account.ipix.id
}

resource "azurerm_cognitive_account" "ipix" {
  count               = var.enable_ai_foundry ? 1 : 0
  kind                = "AIServices"
  location            = var.location
  name                = "ipixai${var.suffix}"
  resource_group_name = azurerm_resource_group.ipix.name
  sku_name            = "S0"
}
