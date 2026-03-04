/******************************
 * modules/products/outputs.tf
 ******************************/
output "id" {
  value = { for k, v in azurerm_api_management_product.prod : k => v.id }
  description = "Map of product key => product resource ID"
}