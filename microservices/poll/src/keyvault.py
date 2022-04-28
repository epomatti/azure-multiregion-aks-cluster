from azure.identity import DefaultAzureCredential
from azure.keyvault.keys import KeyClient
from azure.keyvault.keys.crypto import CryptographyClient, EncryptionAlgorithm
import os

ENCRYPTION_ALGORITHM = EncryptionAlgorithm.rsa_oaep


def encrypt(text: str) -> str:
    crypto_client = _get_cripto_client()
    plaintext = text.encode()
    result = crypto_client.encrypt(ENCRYPTION_ALGORITHM, plaintext)
    return result.ciphertext


def decrypt(ciphertext: str) -> str:
    crypto_client = _get_cripto_client()
    return crypto_client.decrypt(ENCRYPTION_ALGORITHM, ciphertext).plaintext.decode()


def _get_cripto_client():
    uri = os.environ['KEYVAULT_URI']
    credential = DefaultAzureCredential()
    key_client = KeyClient(vault_url=uri, credential=credential)
    key = key_client.get_key("generated-key")
    return CryptographyClient(key, credential=credential)
