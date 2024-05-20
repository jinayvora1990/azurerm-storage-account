resource "azurerm_subscription" "sub" {
  subscription_name = var.subscription_name
}

data "azurerm_management_group" "mgmt_group" {
  name = var.management_group_name
}

resource "azurerm_management_group_subscription_association" "association" {
  management_group_id = data.azurerm_management_group.mgmt_group.id
  subscription_id     = azurerm_subscription.sub.id
}