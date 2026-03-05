locals {
  product_api_matches = {
    for pid, cfg in var.products : pid => [
      for api_name in keys(var.apis_by_name) : api_name
      if length([for pat in cfg.api_name_patterns : pat if can(regex(pat, api_name))]) > 0
    ]
  }
}

resource "azurerm_api_management_product_api" "link" {
  for_each = {
    for pair in flatten([
      for pid, names in local.product_api_matches : [for n in names : { key = "${pid}|${n}", product = pid, api = n }]
    ]) : pair.key => pair
  }
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  product_id          = each.value.product
  api_name            = each.value.api
}
