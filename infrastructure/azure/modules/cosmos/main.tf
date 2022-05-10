resource "azurerm_cosmosdb_account" "default" {
  name                 = "cosmos-${var.root_name}"
  resource_group_name  = var.resource_group_name
  location             = var.main_location
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.0"

  public_network_access_enabled     = true
  is_virtual_network_filter_enabled = true

  # Added Portal and Azure Pulic DCs (https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-configure-firewall)
  ip_range_filter = "0.0.0.0,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26"

  # AKS Subnets
  virtual_network_rule {
    id = var.aks_main_subnet_id
  }

  virtual_network_rule {
    id = var.aks_failover_subnet_id
  }

  # Jumpbox VM Subnets
  virtual_network_rule {
    id = var.jumpbox_main_subnet_id
  }

  virtual_network_rule {
    id = var.jumpbox_failover_subnet_id
  }

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  backup {
    type = "Continuous"
  }

  geo_location {
    location          = var.main_location
    failover_priority = 0
  }

  ### Serverless acounts do not support multiple regions

  # geo_location {
  #   location          = var.failover_location
  #   failover_priority = 1
  # }

  tags = var.tags

}

resource "azurerm_cosmosdb_mongo_database" "poll" {
  name                = "poll"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.default.name
}

resource "azurerm_cosmosdb_mongo_collection" "polls" {
  name                = "polls"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.default.name
  database_name       = azurerm_cosmosdb_mongo_database.poll.name

  index {
    keys   = ["_id"]
    unique = true
  }
}

resource "azurerm_cosmosdb_mongo_database" "vote" {
  name                = "vote"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.default.name
}

resource "azurerm_cosmosdb_mongo_collection" "votes" {
  name                = "votes"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.default.name
  database_name       = azurerm_cosmosdb_mongo_database.vote.name

  index {
    keys   = ["_id"]
    unique = true
  }
}
