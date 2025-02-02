#Define where which Azure region to use
variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

#Define variables for CosmosDB
variable "cosmosdb_name" {
  type        = string
  default     = "skelingtonboi-cosmosdb"
  description = "Name of the CosmosDB instance."
}

#Overall Database Name
variable "cosmosdb_database_name" {
  type        = string
  default     = "CounterDB"
  description = "Name of the CosmosDB database."
}

#Container within the CosmosDB where page count value is stored/incremented
variable "cosmosdb_container_name" {
  type        = string
  default     = "CounterContainer"
  description = "Name of the CosmosDB container."
}