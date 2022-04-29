from . import mongo


def vote(vote):
    return _get_collection().insert_one(vote)


def _get_collection():
    return mongo.get_collection("vote")
