# ========= Basic service =========
resource_group_name = "rg-apim-preprod"
api_management_name = "apim-preprod-001"

# ========= Fragments (upload once, then reuse) =========
fragments = {
  "global-error-handling" = "../../../policies/fragments/global-error-handling.xml"
  "jwt-error-handling"    = "../../../policies/fragments/jwt-error-handling.xml"
  "seacoast-oauth"        = "../../../policies/fragments/seacoast-oauth.xml"
  "debug-error-response"  = "../../../policies/fragments/debug-error-response.xml"
}

# ========= Products + regex link rules =========
products = {
  "quavo" = {
    display_name          = "Quavo"
    description           = "External partner access"
    subscription_required = true
    published             = true
    api_name_patterns     = ["^party-eis-v1$", "^party-fis-v1$"]
    product_policy_path   = "../../../policies/product-policies/quavo.xml"
  }
}

# ========= Subscriptions =========
subscriptions = [
  { display_name = "Quavo – Default", product_id = "quavo" }  # short key, resolved in main.tf
]
# ========= Named Values =========
named_values = {
  "APIM-App-ID" = { display_name = "APIM-App-ID", secret = false, value = "<client-id-guid>" }
  "AzureTenantID" = { display_name = "AzureTenantID", secret = false, value = "<tenant-guid>" }
  # Example Key Vault‑backed secret:
  # "Seacoast-Client-Secret" = {
  #   display_name        = "Seacoast-Client-Secret"
  #   secret              = true
  #   key_vault_secret_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<kv>/secrets/<name>"
  # }
}

# ========= Backends =========
backends = {
  PartyAPI = { url = "https://customer.api.seacoastbank.com", protocol = "https", description = "Party backend" }
}
