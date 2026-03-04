# Remote state (Azure Storage backend)
resource_group_name  = "rg-tfstate-preprod"
storage_account_name = "sttfstatepreprod0001"
container_name       = "tfstate"
key                  = "apim/platform/preprod.tfstate"
