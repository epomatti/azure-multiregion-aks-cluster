import os
import pymongo


def get_collection(db: str, collection: str):
    uri = os.environ['MONGODB_CONNECTION_STRING']
    return pymongo.MongoClient(uri).get_database(db).get_collection(collection)
