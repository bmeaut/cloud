terraform {
  backend "local" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.64"
    }
  }
}
