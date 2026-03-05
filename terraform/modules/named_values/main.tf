resource "azurerm_api_management_named_value" "nv" {
  for_each            = var.named_values
  name                = each.key
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  display_name        = each.value.display_name
  secret              = try(each.value.secret, false)
  value               = try(each.value.key_vault_secret_id, null) == null ? try(each.value.value, null) : null
  dynamic "value_from_key_vault" {
    for_each = try(each.value.key_vault_secret_id, null) != null ? [1] : []
    content {
      secret_id          = each.value.key_vault_secret_id
      identity_client_id = try(each.value.identity_client_id, null)
    }
  }
  tags = try(each.value.tags, [])
}
