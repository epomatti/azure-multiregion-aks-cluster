import os
import pymongo


def get_client():
    uri = os.environ['COSMOSDB_CONNECTION_STRING']
    return pymongo.MongoClient(uri)
