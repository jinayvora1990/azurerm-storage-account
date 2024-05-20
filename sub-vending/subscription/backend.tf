terraform {
  backend "azurerm" {
    resource_group_name  = "sub_vending_resource_group"
    storage_account_name = "sub_vending_sa"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}