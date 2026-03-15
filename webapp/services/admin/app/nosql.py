import os

import oci
from borneo import NoSQLHandle, NoSQLHandleConfig
from borneo.iam import SignatureProvider


def get_nosql_handle():
    region = os.getenv("OCI_REGION", "sa-saopaulo-1")
    endpoint = f"https://nosql.{region}.oci.oraclecloud.com"

    provider = SignatureProvider(
        config_file="~/.oci/config",
        profile_name=os.getenv("OCI_PROFILE", "DEFAULT"),
    )

    return NoSQLHandle(NoSQLHandleConfig(endpoint, provider))


def get_pizzas_table_name():
    return os.getenv("TABLE_NAME", "pizzas")


def get_compartment_id():
    compartment_id = (os.getenv("COMPARTMENT_ID") or "").strip()
    if not compartment_id:
        raise RuntimeError("COMPARTMENT_ID is required for NoSQL access")
    return compartment_id
