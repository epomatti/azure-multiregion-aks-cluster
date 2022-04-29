from bson import ObjectId
from . import mongo


def create_poll(poll):
    poll['votes'] = {'count': 0}
    return _get_collection().insert_one(poll)


def find_poll(id):
    return _get_collection().find_one({'_id': ObjectId(id)})


def increment_votes(id):
    _get_collection().update_one({'_id': ObjectId(id)},
                                 {'$inc': {'votes.count': 1}})


def _get_collection():
    return mongo.get_collection("poll", "polls")
