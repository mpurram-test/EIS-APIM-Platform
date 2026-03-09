# look up the APIM service to obtain its ID (required by newer provider versions)
data "azurerm_api_management" "apim" {
  name                = var.api_management_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_api_management_policy_fragment" "fragment" {
  for_each          = var.fragments
  api_management_id = data.azurerm_api_management.apim.id
  name              = each.key
  value             = file(each.value)
}
