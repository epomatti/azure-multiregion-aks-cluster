import os
import pymongo
from . import keyvault


def get_collection(db: str, collection: str):
    connection_string = keyvault.get_cosmos_connection_string()
    return pymongo.MongoClient(connection_string).get_database(db).get_collection(collection)
