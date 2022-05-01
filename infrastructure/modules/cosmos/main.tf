resource "azurerm_cosmosdb_account" "default" {
  name                 = "cosmos-${var.application_name}"
  resource_group_name  = var.resource_group_name
  location             = var.main_location
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.0"
  enable_free_tier     = var.enable_free_tier

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  capacity {
    total_throughput_limit = var.total_throughput_limit
  }

  geo_location {
    location          = var.main_location
    failover_priority = 0
  }

  # geo_location {
  #   location          = var.failover_location
  #   failover_priority = 1
  # }

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
