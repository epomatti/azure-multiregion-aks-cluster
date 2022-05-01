from azure.identity import DefaultAzureCredential
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import os


def _load_cosmos_connection_string():
    url = os.environ['KEYVAULT_URL']
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url=url, credential=credential)
    return secret_client.get_secret("cosmos-connection-string").value


_secret = _load_cosmos_connection_string()


def get_cosmos_connection_string():
    return _secret
