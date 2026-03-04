resource "azurerm_api_management_product_policy" "pol" {
  for_each            = var.product_policies
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  product_id          = each.key
  xml_content         = file(each.value)
}
