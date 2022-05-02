import os
import pymongo
from . import keyvault


def get_collection(database: str, collection: str):
    use_keyvault = bool(os.environ['USE_KEYVAULT'])
    connection_string = ""
    if use_keyvault:
        connection_string = keyvault.get_cosmos_uri()
    else:
        connection_string = os.environ['MONGODB_CONNECTION_STRING']
    return pymongo.MongoClient(connection_string).get_database(database).get_collection(collection)
