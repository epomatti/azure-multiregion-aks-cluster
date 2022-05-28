import os

from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from . import utils
from . import msal


def get_cosmos_connection_string():
    return _get_secret("cosmosdb-connection-string")


def _get_secret(secret: str):
    url = os.environ['KEYVAULT_URL']
    use_token_credential = utils.to_bool(os.environ['USE_TOKEN_CREDENTIAL'])
    if use_token_credential is True:
        credential = msal.get_token_credential()
    else:
        credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url=url, credential=credential)
    return secret_client.get_secret(secret).value
