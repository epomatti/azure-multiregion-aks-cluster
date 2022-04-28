import os
import pymongo

def get_collection(collection: str):
    uri = os.environ['MONGODB_CONNECTION_STRING']
    database = os.environ['MONGODB_DATABASE']
    return pymongo.MongoClient(uri).get_database(database).get_collection(collection)
