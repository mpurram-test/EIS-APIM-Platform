data "azurerm_api_management" "apim" {
  name                = var.api_management_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_api_management_policy" "global" {
  api_management_id = data.azurerm_api_management.apim.id
  xml_content       = var.xml_content
}
