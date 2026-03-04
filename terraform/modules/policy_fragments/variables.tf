variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "fragments" { type = map(string) } # id => path to XML
