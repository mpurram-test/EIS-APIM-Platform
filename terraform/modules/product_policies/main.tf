resource "azurerm_api_management_product_policy" "pol" {
  for_each            = var.product_policies
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  product_id          = each.key
  # treat paths as relative to the workspace root (two levels above the env dir)
  # path.root points to the directory containing the root module (e.g. terraform/envs/preprod).
  # Two levels up lands in terraform/; three levels up reaches the repository root where
  # the policies directory actually lives.
  xml_content = file(
    abspath("${path.root}/../../../${each.value}")
  )
}
