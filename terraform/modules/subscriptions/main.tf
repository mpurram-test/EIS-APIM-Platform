resource "azurerm_api_management_subscription" "subscription" {
  for_each            = { for s in var.subscriptions : s.display_name => s }
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  display_name        = each.value.display_name
  product_id          = each.value.product_id
  user_id             = try(each.value.user_id, null)
  state               = try(each.value.state, "active")
}
