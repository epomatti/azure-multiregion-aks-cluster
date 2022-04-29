from flask import Flask, request

from src import repository
from src.validators import validate_schema
from src.schemas import vote_schema

app = Flask(__name__)


@app.route("/vote", methods=['HEAD'])
def head():
    return ""


@validate_schema(schema=vote_schema)
@app.route("/vote", methods=['POST'])
def post():
    vote_json = request.get_json()
    id = vote_json['id']
    repository.vote(vote_json)
