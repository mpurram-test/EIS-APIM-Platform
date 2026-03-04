variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "subscriptions" {
  type = list(object({
    display_name = string
    product_id   = string
    user_id      = optional(string)
    state        = optional(string, "active")
  }))
}
