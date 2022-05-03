pool_schema = {
    'name': {'type': 'string', 'required': True},
    'desc': {'type': 'string', 'required': True},
    'options': {
        'type': 'list',
        'schema': {
            'type': 'string',
            'required': True
        },
        'minlength': 2,
        'maxlength': 5,
        'required': True
    },
}

increment_schema = {
    'id': {'type': 'string', 'required': True}
}

validate_schema = {
    'id': {'type': 'string', 'required': True},
    'option': {'type': 'string', 'required': True}
}
