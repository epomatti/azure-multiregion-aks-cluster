from azure.identity import DefaultAzureCredential
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
import os


def _get_secret(secret: str):
    url = os.environ['KEYVAULT_URL']
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url=url, credential=credential)
    return secret_client.get_secret(secret).value
