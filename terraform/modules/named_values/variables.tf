variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "named_values" {
  description = "name => { display_name, value?, secret?, key_vault_secret_id?, identity_client_id?, tags? }"
  type = map(object({
    display_name        = string
    value               = optional(string)
    secret              = optional(bool, false)
    key_vault_secret_id = optional(string)
    identity_client_id  = optional(string)
    tags                = optional(list(string), [])
  }))
}
