
# # Backend: PartyAPI
# import {
#   to = module.backends.azurerm_api_management_backend.backend["PartyAPI"]
#   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/backends/PartyAPI"
# }

# # Named Value: APIM-App-ID
# import {
#   to = module.named_values.azurerm_api_management_named_value.named_value["APIM-App-ID"]
#   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/namedValues/APIM-App-ID"
# }

# # Named Value: AzureTenantID
# import {
#   to = module.named_values.azurerm_api_management_named_value.named_value["AzureTenantID"]
#   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/namedValues/AzureTenantID"
# }



# # # Product
# # import {
# #   to = module.products.azurerm_api_management_product.prod["<PRODUCT_ID>"]
# #   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/products/<PRODUCT_ID>"
# # }

# # # Product Policy
# # import {
# #   to = module.product_policies.azurerm_api_management_product_policy.policy["<PRODUCT_ID>"]
# #   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/products/<PRODUCT_ID>/policies/policy"
# # }

# # # Product–API link (note the key is often "<PRODUCT_ID>|<API_NAME>")
# # import {
# #   to = module.links.azurerm_api_management_product_api.link["<PRODUCT_ID>|<API_NAME>"]
# #   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/products/<PRODUCT_ID>/apis/<API_NAME>"
# # }

# # # Subscription (key depends on your module; stable if keyed by subscription GUID)
# # import {
# #   to = module.subscriptions.azurerm_api_management_subscription.sub["<SUBSCRIPTION_ID_OR_KEY>"]
# #   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/subscriptions/<SUBSCRIPTION_ID>"
# # }

# # # Policy Fragment
# # import {
# #   to = module.policy_fragments.azurerm_api_management_policy_fragment.fragment["<FRAGMENT_ID>"]
# #   id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ApiManagement/service/${var.api_management_name}/policyFragments/<FRAGMENT_ID>"
# # }