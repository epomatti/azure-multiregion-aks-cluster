from flask import Flask

from .mongo import get_client


def create_app():
    app = Flask(__name__)

    @app.route("/vote", methods=['HEAD'])
    def head():
        return ""

    @app.route("/vote/<poll>", methods=['POST'])
    def post(poll: int):
        collection = get_client().get_database('vote').get_collection('votes')
        result = collection.insert_one({"poll": 1})
        return {
            "response": str(result.inserted_id)
        }

    return app
