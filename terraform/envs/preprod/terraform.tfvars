
# ========= Fragments (upload once, then reuse) =========
fragments = {
  "global-error-handling" = "../../../policies/fragments/global-error-handling.xml"
  "jwt-error-handling"    = "../../../policies/fragments/jwt-error-handling.xml"
  "seacoast-oauth"        = "../../../policies/fragments/seacoast-oauth.xml"
  "debug-error-response"  = "../../../policies/fragments/debug-error-response.xml"
}

# ========= Products + regex link rules =========
products = {
  quavo = {
    display_name          = "Quavo"
    description           = "External partner access (updated description at $(date))"
    subscription_required = true
    published             = true
    api_name_patterns     = ["^party-reference-data-directory-eis-v1$"]
    # Keep this just a simple, repo-relative path (or even just the file name)
    product_policy_path = "policies/product-policies/quavo.xml"
  }

  seacoast-internal = {
    display_name          = "Seacoast Internal"
    description           = "Internal partner access (v2 updated)"
    subscription_required = true
    published             = true
    api_name_patterns     = ["^party-reference-data-directory-eis-v1$", "^party-reference-data-directory-fis-v1$"]
    product_policy_path   = "policies/product-policies/seacoastInternal.xml"
  }
}
# ========= Subscriptions =========
subscriptions = [
  { display_name = "Quavo - Default", product_id = "quavo" },
  { display_name = "Seacoast Internal - Default", product_id = "seacoast-internal" }
]

# ========= Named Values =========
named_values = {
  "APIM-App-ID"   = { display_name = "APIM-App-ID", secret = false, value = "<client-id-guid>" }
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
