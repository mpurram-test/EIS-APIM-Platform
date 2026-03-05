variable "resource_group_name" { type = string }
variable "api_management_name" { type = string }
variable "backends" {
  description = "backend_name => { url, protocol, description? }"
  type = map(object({
    url         = string
    # provider accepts only "http" or "soap"; if you supply "https" it will be automatically
    # converted to "http" while leaving the URL intact (so secure endpoints work correctly).
    protocol    = string
    description = optional(string)
  }))
  # simple validation to catch obvious typos
  validation {
    condition = alltrue([
      for b in values(var.backends) :
      b.protocol == "http" || b.protocol == "https" || b.protocol == "soap"
    ])
    error_message = "backend.protocol must be one of http, https or soap. https is allowed but mapped to http."
  }
}
