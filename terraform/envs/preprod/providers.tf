terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.110" }
    azapi   = { source = "Azure/azapi",       version = "~> 2.8" }
  }
  backend "azurerm" {}
}
provider "azurerm" { features {} }
provider "azapi"   {}
