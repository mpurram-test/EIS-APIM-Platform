resource "azurerm_api_management_backend" "backend" {
  for_each            = var.backends
  name                = each.key
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  # the provider only accepts "http" or "soap"; users may specify "https" in var
  protocol = each.value.protocol == "https" ? "http" : each.value.protocol
  url                 = each.value.url
  description         = try(each.value.description, null)
}
