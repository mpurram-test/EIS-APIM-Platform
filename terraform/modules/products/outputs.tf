output "id" {
  value       = { for k, v in azurerm_api_management_product.product : k => v.id }
  description = "Map of product key => product resource ID"
}
