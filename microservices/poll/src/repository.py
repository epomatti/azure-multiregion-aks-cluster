from . import mongo


def create_poll(poll):
    return _get_collection().insert_one(poll)


def _get_collection():
    return mongo.get_collection("poll")
