variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "products" {
  description = "pid => { api_name_patterns }"
  type = map(object({
    api_name_patterns = list(string)
  }))
}
variable "apis_by_name" {
  description = "Map of API name => { id, name }"
  type        = map(object({ id = string, name = string }))
}
