from bson import ObjectId
from . import mongo


def create_poll(poll):
    return _get_collection().insert_one(poll)


def find_poll(id):
    return _get_collection().find_one({'_id': ObjectId(id)})


def _get_collection():
    return mongo.get_collection("poll")
