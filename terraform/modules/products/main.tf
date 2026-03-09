resource "azurerm_api_management_product" "product" {
  for_each              = var.products
  product_id            = each.key
  resource_group_name   = var.resource_group_name
  api_management_name   = var.api_management_name
  display_name          = each.value.display_name
  description           = try(each.value.description, null)
  subscription_required = try(each.value.subscription_required, true)
  approval_required     = try(each.value.approval_required, false)
  published             = try(each.value.published, true)
  terms                 = try(each.value.terms, null)
}
