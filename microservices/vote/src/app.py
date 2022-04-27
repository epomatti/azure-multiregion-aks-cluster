from flask import Flask
from dotenv import load_dotenv
from .mongo import get_client

load_dotenv()


def create_app():
    app = Flask(__name__)

    @app.route("/vote", methods=['HEAD'])
    def head():
        return ""

    @app.route("/vote/<poll>", methods=['POST'])
    def post(poll: int):
        collection = get_client().get_database('app').get_collection('votes')
        result = collection.insert_one({"poll": 1})
        return {
            "response": str(result.inserted_id)
        }

    return app

if __name__ == '__main__':
    app = create_app()
    app.run()
