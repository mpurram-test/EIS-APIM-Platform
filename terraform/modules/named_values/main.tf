locals {
  # for_each keys cannot be sensitive; values can remain sensitive.
  named_value_keys = toset(keys(nonsensitive(var.named_values)))
}

resource "azurerm_api_management_named_value" "named_value" {
  for_each            = local.named_value_keys
  name                = each.key
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  display_name        = var.named_values[each.key].display_name
  secret              = try(var.named_values[each.key].secret, false)
  value               = try(var.named_values[each.key].key_vault_secret_id, null) == null ? try(var.named_values[each.key].value, null) : null

  dynamic "value_from_key_vault" {
    for_each = try(var.named_values[each.key].key_vault_secret_id, null) != null ? [1] : []
    content {
      secret_id          = var.named_values[each.key].key_vault_secret_id
      identity_client_id = try(var.named_values[each.key].identity_client_id, null)
    }
  }

  tags = try(var.named_values[each.key].tags, [])
}
