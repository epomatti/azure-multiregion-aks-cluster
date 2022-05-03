import os
from pymongo import MongoClient
from . import keyvault
from . import utils


def get_collection(database: str, collection: str):
    use_keyvault = utils.to_bool(os.environ['USE_KEYVAULT'])
    if use_keyvault is True:
        connection_string = keyvault.get_cosmos_connection_string()
    else:
        connection_string = os.environ['COSMOSDB_CONNECTION_STRING']
    return MongoClient(connection_string).get_database(database).get_collection(collection)
