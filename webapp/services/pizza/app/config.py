#
# pizza/app/config.py
#

from pydantic_settings import BaseSettings
from functools import lru_cache

import oci
from borneo import NoSQLHandleConfig, NoSQLHandle
from borneo.iam import SignatureProvider

class Settings(BaseSettings):
    ENVIRONMENT: str = "dev"

    OCI_REGION: str
    COMPARTMENT_ID: str
    TABLE_NAME: str
    JWT_SECRET: str = "change-me-auth-secret"
    OBJECT_STORAGE_NAMESPACE: str = ""
    BUCKET_PIZZAS_IMG: str = "pizzas-img"

    OCI_PROFILE: str = "DEFAULT"

    class Config:
        env_file = ".env"

@lru_cache
def get_settings():
    return Settings()

def get_nosql_handle():
    settings = get_settings()

    endpoint = f"https://nosql.{settings.OCI_REGION}.oci.oraclecloud.com"

    # DEVELOPMENT - ~/.oci/config
    if settings.ENVIRONMENT == "dev":
        provider = SignatureProvider(
            config_file="~/.oci/config",
            profile_name=settings.OCI_PROFILE
        )

    # PRODUCTION - Instance Principal
    else:
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()

        provider = SignatureProvider(
            signer=signer,
            region=settings.OCI_REGION,
        )

    handle_config = NoSQLHandleConfig(endpoint, provider)

    return NoSQLHandle(handle_config)


def get_object_storage_client():
    settings = get_settings()

    if settings.ENVIRONMENT == "dev":
        config = oci.config.from_file(profile_name=settings.OCI_PROFILE)
        client = oci.object_storage.ObjectStorageClient(config)
    else:
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        client = oci.object_storage.ObjectStorageClient({}, signer=signer)

    client.base_client.set_region(settings.OCI_REGION)
    return client
