resource "azurerm_api_management_policy" "global" {
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  xml_content         = var.xml_content
}
