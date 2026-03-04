resource "azurerm_api_management_backend" "b" {
  for_each            = var.backends
  name                = each.key
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  protocol            = each.value.protocol
  url                 = each.value.url
  description         = try(each.value.description, null)
}
