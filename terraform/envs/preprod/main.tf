# Discover APIM service & list existing APIs #


data "azurerm_api_management" "apim" {
  name                = var.api_management_name
  resource_group_name = var.resource_group_name
}

# Generic AzAPI list to enumerate all APIs under the APIM service
data "azapi_resource_list" "apis" {
  type                   = "Microsoft.ApiManagement/service/apis@2022-08-01"
  parent_id              = data.azurerm_api_management.apim.id
  response_export_values = ["*"]
}

locals {
  # azapi_resource_list output may be either:
  # 1) an object with .value array, or
  # 2) a JSON string (sometimes nested under .value).
  apis_output_any = try(
    data.azapi_resource_list.apis.output.value,
    data.azapi_resource_list.apis.output,
    {}
  )

  apis_output_obj = try(jsondecode(local.apis_output_any), local.apis_output_any)
  apis_raw        = try(local.apis_output_obj.value, [])
  apis_by_name    = { for a in local.apis_raw : a.name => { id = a.id, name = a.name } }
}

# Upload policy fragments

module "policy_fragments" {
  source              = "../../modules/policy_fragments"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name

  # Pass from env tfvars: map(fragment_id => relative XML path)
  fragments = var.fragments

  # OAuth fragment references APIM Named Values such as {{AzureTenantID}} and {{APIM-App-ID}}.
  depends_on = [module.named_values]
}

# Create products

module "products" {
  source              = "../../modules/products"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name

  # Map the richer env var schema down to the module’s product shape
  products = {
    for pid, cfg in var.products : pid => {
      display_name          = cfg.display_name
      description           = try(cfg.description, null)
      subscription_required = try(cfg.subscription_required, true)
      approval_required     = try(cfg.approval_required, false)
      published             = try(cfg.published, true)
      terms                 = try(cfg.terms, null)

      api_name_patterns   = cfg.api_name_patterns
      product_policy_path = try(cfg.product_policy_path, null)
    }
  }

  depends_on = [module.policy_fragments]
  # Products should be created after any fragments so policies can reference them
}

# Attach product-level policy (XML) 

module "product_policies" {
  source              = "../../modules/product_policies"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name

  # Only include products that specify a product_policy_path
  product_policies = {
    for pid, cfg in var.products : pid => try(cfg.product_policy_path, null)
    if try(cfg.product_policy_path, null) != null
  }

  # Ensure fragments & products exist before policy attachment
  depends_on = [module.policy_fragments, module.products]
}

# Create Product→API links (regex-based)  

module "links" {
  source              = "../../modules/product_api_links"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name

  # Pass only the fields the linking module needs
  products = {
    for pid, cfg in var.products : pid => {
      api_name_patterns = cfg.api_name_patterns
      # If you removed strict_min_match from the module/vars, drop this next line:
      strict_min_match = try(cfg.strict_min_match, null)
    }
  }

  # The discovered APIs
  apis_by_name = local.apis_by_name

  # Products must exist before linking
  depends_on = [module.products]
}

# Build product_id map for subscriptions 

# The products module must export a map(pid => resource id) as output "id".
# In modules/products/outputs.tf:
# output "id" { value = { for k, v in azurerm_api_management_product.prod : k => v.id } }

locals {
  product_ids_by_pid = try(module.products.id, {})

  # Remap each subscription so 'product_id' becomes the product resource ID.
  # This lets you use the short key (e.g., "quavo") in terraform.tfvars.
  subscriptions_with_ids = [
    for s in var.subscriptions : merge(
      s,
      { product_id = lookup(local.product_ids_by_pid, s.product_id, s.product_id) }
    )
  ]
}

# Subscriptions (per product)

module "subscriptions" {
  source              = "../../modules/subscriptions"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name

  # Now includes full resource ID in product_id
  subscriptions = local.subscriptions_with_ids

  # Ensure products exist before creating subscriptions
  depends_on = [module.products]
}

# Named Values (incl. KeyVault)

module "named_values" {
  source              = "../../modules/named_values"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  named_values        = var.named_values
  depends_on          = [data.azurerm_api_management.apim]
}

# Backends 

module "backends" {
  source              = "../../modules/backends"
  resource_group_name = var.resource_group_name
  api_management_name = var.api_management_name
  backends            = var.backends
  depends_on          = [data.azurerm_api_management.apim]
}

