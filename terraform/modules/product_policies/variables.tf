variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "product_policies" { type = map(string) } # product_id => xml path
