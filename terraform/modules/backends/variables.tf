variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "backends" {
  description = "backend_name => { url, protocol, description? }"
  type = map(object({
    url         = string
    protocol    = string
    description = optional(string)
  }))
}
