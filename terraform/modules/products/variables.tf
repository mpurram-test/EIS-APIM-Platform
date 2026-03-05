variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "products" {
  description = "Product catalog with regex link rules"
  type = map(object({
    display_name          = string
    description           = optional(string)
    subscription_required = optional(bool, true)
    approval_required     = optional(bool, false)
    published             = optional(bool, true)
    terms                 = optional(string)

    # REQUIRED for linking module
    api_name_patterns = list(string)

    # REQUIRED for product-level policies
    product_policy_path = optional(string)
  }))
}
