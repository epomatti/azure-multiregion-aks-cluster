import os
import requests

POOL_SERVER = os.environ['POLL_API']


def increment_pool(pool_id):
    data = {"pool_id": pool_id}
    r = requests.post(f'{POOL_SERVER}/api/poll', json=data)
    r.raise_for_status()
