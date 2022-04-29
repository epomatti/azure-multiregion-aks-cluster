from functools import wraps
from flask import (
    jsonify,
    request,
)
from cerberus import Validator


def validate_schema(schema):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kw):
            v = Validator(schema)
            if not v.validate(request.json):
                return jsonify({"error": v.errors}), 400
            return f(*args, **kw)
        return wrapper
    return decorator
