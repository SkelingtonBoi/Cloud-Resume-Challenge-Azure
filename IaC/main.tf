#Static Site Resource Group
resource "azurerm_resource_group" "Static_Site" {
  location = var.resource_group_location
  name     = "Static_Site"
}
#Resource Group for API
resource "azurerm_resource_group" "Static_Site_API" {
  location = var.resource_group_location
  name     = "Static_Site_API"
}
#Storage Account for Static Site
resource "azurerm_storage_account" "CloudResumeStorage" {
  name                     = "skelingtonboistorage"
  location                 = var.resource_group_location
  resource_group_name      = azurerm_resource_group.Static_Site.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
#Container for the Website Code
resource "azurerm_storage_container" "Website" {
  name                  = "$web"
  storage_account_id    = azurerm_storage_account.CloudResumeStorage.id
  container_access_type = "private"
}
#Content Delivery Network
resource "azurerm_cdn_profile" "CDN_Profile" {
  name                = "cdn-skelingtonboi-profile"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.Static_Site.name
  sku                 = "Standard_Microsoft"
}
#CDN Endpoint that will host the website
resource "azurerm_cdn_endpoint" "CDN_Endpoint" {
  name                = "cdn-skelingtonboi-endpoint"
  profile_name        = azurerm_cdn_profile.CDN_Profile.name
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.Static_Site.name
  origin_host_header  = azurerm_storage_account.CloudResumeStorage.primary_web_host
  #origin_host_header = azurerm_storage_blob.Website.name
  origin {
    name      = "skelingtonboi-endpoint"
    host_name = azurerm_storage_account.CloudResumeStorage.primary_web_host
  }
}
#Custom domain "www.skelingtonboi.com" associated with the CDN endpoint "cdn-skelingtonboi-endpoint"
#HTTPS is enabled and managed via the CDN
resource "azurerm_cdn_endpoint_custom_domain" "skelingtonboi-website" {
  name            = "skelingtonboi"
  cdn_endpoint_id = azurerm_cdn_endpoint.CDN_Endpoint.id
  host_name       = "www.skelingtonboi.com"
  cdn_managed_https {
    tls_version      = "TLS12"
    certificate_type = "Dedicated"
    protocol_type    = "ServerNameIndication"
  }
}
#CosmsosDB Database Account
resource "azurerm_cosmosdb_account" "skelingtonboi-cosmosdb" {
  name     = var.cosmosdb_name
  location = var.resource_group_location
  geo_location {
    location          = var.resource_group_location
    failover_priority = 0
  }
  resource_group_name = azurerm_resource_group.Static_Site_API.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "Session"
  }
}
#Cosmos Database Itself
resource "azurerm_cosmosdb_sql_database" "CounterDB" {
  name                = var.cosmosdb_database_name
  resource_group_name = azurerm_resource_group.Static_Site_API.name
  account_name        = azurerm_cosmosdb_account.skelingtonboi-cosmosdb.name
}
#CosmosDB Container
resource "azurerm_cosmosdb_sql_container" "CounterContainer" {
  name                  = var.cosmosdb_container_name
  resource_group_name   = azurerm_resource_group.Static_Site_API.name
  account_name          = azurerm_cosmosdb_account.skelingtonboi-cosmosdb.name
  database_name         = var.cosmosdb_database_name
  partition_key_paths   = ["/id"]
  partition_key_version = 1
}
#Azure Function
#Storage Account for Azure Function
# resource "azurerm_storage_account" "GetResumeCountStorage" {
#   name                     = "getresumecountstorage"
#   location                 = var.resource_group_location
#   resource_group_name      = azurerm_resource_group.Static_Site_API.name
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }
#Consumption Plan for Azure Function
# resource "azurerm_service_plan" "LinuxServicePlan" {
#   name                = "linuxserviceplan"
#   resource_group_name = azurerm_resource_group.Static_Site_API.name
#   location            = var.resource_group_location
#   os_type             = "Linux"
#   sku_name            = "FC1"
# }
# resource "azapi_resource" "FlexPlan" {
#   type      = "Microsoft.Web/serverfarms@2022-03-01"
#   name      = "flex"
#   parent_id = azurerm_resource_group.Static_Site_API.id
#   body = {
#     kind     = "functionapp"
#     location = "southcentralus"
#     sku = {
#       name = "FC1"
#       tier = "FlexConsumption"
#     }
#   }
# }
#Application Insights
# resource "azurerm_application_insights" "GetResumeCount_Insights" {
#   name                = "GetResumeCount-Python_Insights"
#   location            = "southcentralus"
#   resource_group_name = azurerm_resource_group.Static_Site_API.name
#   application_type    = "web"
# }
#Azure Function itself
# resource "azurerm_linux_function_app" "CounterFunction" {
#   name                       = "GetResumeCount-PythonProd"
#   location                   = "southcentralus"
#   resource_group_name        = azurerm_resource_group.Static_Site_API.name
#   storage_account_name       = azurerm_storage_account.GetResumeCountStorage.name
#   storage_account_access_key = azurerm_storage_account.GetResumeCountStorage.primary_access_key
#   service_plan_id            = azapi_resource.FlexPlan.id
#   site_config {
#     application_stack {
#       python_version = "3.11"
#     }
#   }
# }