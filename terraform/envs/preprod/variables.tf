variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }

variable "fragments" {
  type    = map(string)
  default = {}
}

variable "products" {
  description = "Product catalog with regex link rules"
  type = map(object({
    display_name          = string
    description           = optional(string)
    subscription_required = optional(bool, true)
    approval_required     = optional(bool, false)
    published             = optional(bool, true)
    terms                 = optional(string)
    api_name_patterns     = list(string)
    product_policy_path   = optional(string)
  }))
  default = {}
}

variable "subscriptions" {
  type = list(object({
    display_name = string
    product_id   = string
    user_id      = optional(string)
    state        = optional(string, "active")
  }))
  default = []
}

variable "named_values" {
  type = map(object({
    display_name        = string
    value               = optional(string)
    secret              = optional(bool, false)
    key_vault_secret_id = optional(string)
    identity_client_id  = optional(string)
    tags                = optional(list(string), [])
  }))
  default = {}
}

variable "backends" {
  type = map(object({
    url         = string
    protocol    = string
    description = optional(string)
  }))
  default = {}
}
