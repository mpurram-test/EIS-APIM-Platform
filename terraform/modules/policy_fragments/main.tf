resource "azurerm_api_management_policy_fragment" "this" {
  for_each            = var.fragments
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  name                = each.key
  value               = file(each.value)
}
