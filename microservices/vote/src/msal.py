# pylint: disable=line-too-long
# Source from: https://github.com/Azure/azure-workload-identity/blob/main/examples/msal-python/token_credential.py

import os
from .token_credential import ClientAssertionCredential

# pylint: disable=consider-using-f-string


def get_token_credential():
    # get environment variables to authenticate to the key vault
    azure_client_id = os.getenv('AZURE_CLIENT_ID', '')
    azure_tenant_id = os.getenv('AZURE_TENANT_ID', '')
    azure_authority_host = os.getenv('AZURE_AUTHORITY_HOST', '')
    azure_federated_token_file = os.getenv('AZURE_FEDERATED_TOKEN_FILE', '')

    # create a token credential object, which has a get_token method that returns a token
    token_credential = ClientAssertionCredential(
        azure_client_id, azure_tenant_id, azure_authority_host, azure_federated_token_file)

    return token_credential
