import os
import requests

POOL_SERVER = os.environ['POLL_API']


def increment_pool(pool_id):
    data = {"id": pool_id}
    r = requests.patch(f'{POOL_SERVER}/api/polls/inc', json=data)
    r.raise_for_status()
