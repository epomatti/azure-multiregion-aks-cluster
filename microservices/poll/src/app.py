from array import array
from flask import request, Flask, jsonify
from cerberus import Validator

from src.validators import validate_schema
from src import repository


pool_schema = {
    'name': {'type': 'string', 'required': True},
    'desc': {'type': 'string', 'required': True},
    'options': {'type': 'list', 'schema': {'type': 'string', 'required': True}, 'minlength': 2, 'maxlength': 5, 'required': True},
}


def create_app():
    app = Flask(__name__)

    @app.route("/poll", methods=['HEAD'])
    def head():
        return ""

    @app.route("/poll", methods=['POST'])
    @validate_schema(schema=pool_schema)
    def post():
        result = repository.create_poll(request.get_json())
        return {"id": str(result.inserted_id)}, 201

    @app.route("/poll/<id>", methods=['GET'])
    def get(id):
        poll = repository.find_poll(id)
        poll['_id'] = str(poll['_id'])
        return poll

    return app
