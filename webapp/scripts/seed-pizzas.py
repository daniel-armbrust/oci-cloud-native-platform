"""
OCI Pizza Platform

Script: seed-pizzas.py

Descrição:
    Script responsável por inicializar o catálogo de pizzas da aplicação
    OCI Pizza. O script executa duas operações principais:

    1. Insere os registros de pizzas na tabela "pizzas" do OCI NoSQL Database.
    2. Faz upload das imagens das pizzas para um bucket no OCI Object Storage.

Funcionamento:
    - Lê os dados do arquivo JSON localizado em:
        data/nosql/pizzas.jsonl

    - Lê as imagens das pizzas localizadas em:
        assets/pizzas/

    - Para cada pizza:
        - faz upload da imagem no Object Storage
        - insere o registro correspondente na tabela NoSQL

Autenticação:
    Desenvolvimento:
        Utiliza arquivo de configuração OCI (~/.oci/config) montado no container.

    Produção:
        Utiliza Resource Principal / Dynamic Group do OCI.

Variáveis de ambiente:
    NOSQL_TABLE          Nome da tabela NoSQL (ex: pizzas)
    OCI_BUCKET           Bucket do Object Storage
    OCI_REGION           Região OCI
    OCI_COMPARTMENT_ID   OCID do compartment

Uso:
    Este script é executado automaticamente durante o bootstrap do ambiente
    (make install / docker compose seed) para popular os dados iniciais
    do catálogo.

Projeto:
    OCI Pizza – Plataforma de pedidos de pizzaria baseada em microserviços
    executando no Oracle Kubernetes Engine (OKE).
"""

import os
import json
import mimetypes
from pathlib import Path

import oci

from borneo.iam import SignatureProvider
from borneo import NoSQLHandleConfig, NoSQLHandle, PutRequest

# ------------------------------------------------------------
# Environment variables
# ------------------------------------------------------------

COMPARTMENT_ID = os.getenv("COMPARTMENT_ID")
OCI_REGION = os.getenv("OCI_REGION", "sa-saopaulo-1")

TABLE_NAME = os.getenv("NOSQL_PIZZAS_TABLE", "pizzas")
BUCKET_NAME = os.getenv("BUCKET_PIZZAS_IMG", "pizzas-imgs")

DATA_FILE = os.getenv("PIZZAS_DATA_FILE", "./data/nosql/pizzas.json")
ASSETS_DIR = os.getenv("PIZZAS_ASSETS_DIR", "./assets/pizzas")

# ------------------------------------------------------------
# OCI authentication
# ------------------------------------------------------------

def get_oci_clients():
    if os.environ.get("OCI_RESOURCE_PRINCIPAL_VERSION"):
        print("Using Resource Principal authentication")

        signer = oci.auth.signers.get_resource_principals_signer()
        object_client = oci.object_storage.ObjectStorageClient({}, signer=signer)
        provider = SignatureProvider(signer)
    else:
        print("Using ~/.oci/config authentication")

        config = oci.config.from_file()

        signer = oci.signer.Signer(
            tenancy=config["tenancy"],
            user=config["user"],
            fingerprint=config["fingerprint"],
            private_key_file_location=config["key_file"],
            pass_phrase=config.get("pass_phrase")
        )

        object_client = oci.object_storage.ObjectStorageClient(config)
        provider = SignatureProvider(signer)

    object_client.base_client.set_region(OCI_REGION)

    return object_client, provider

# ------------------------------------------------------------
# Object Storage
# ------------------------------------------------------------

def upload_assets(object_client):
    namespace = object_client.get_namespace().data

    print("Uploading pizza images...")

    for image_path in Path(ASSETS_DIR).glob("*"):
        print(f"Uploading {image_path.name}")

        content_type, _ = mimetypes.guess_type(image_path)

        with open(image_path, "rb") as f:
            object_client.put_object(
                namespace_name=namespace,
                bucket_name=BUCKET_NAME,
                object_name=image_path.name,
                put_object_body=f,
                content_type=content_type or "application/octet-stream"
            )


# ------------------------------------------------------------
# NoSQL
# ------------------------------------------------------------

def create_nosql_handle(provider):
    endpoint = f"https://nosql.{OCI_REGION}.oci.oraclecloud.com"
    config = NoSQLHandleConfig(endpoint, provider)

    print(endpoint)
    return NoSQLHandle(config)

def insert_pizza(handle, row):
    request = PutRequest()
    request.set_table_name(TABLE_NAME)
    request.set_compartment(COMPARTMENT_ID)
    request.set_value(row)

    handle.put(request)

def load_pizzas(handle):
    print("Loading pizza data...")

    with open(DATA_FILE) as f:
        for line in f:
            pizza = json.loads(line)

            row = {
                "id": pizza["id"],
                "slug": pizza["slug"],
                "name": pizza["name"],
                "description": pizza.get("description"),
                "category": pizza["category"],
                "available": pizza["available"],
                "sizes": pizza["sizes"],
                "image_url": pizza["image_url"]
            }

            print(f"Inserting {pizza['name']}")
            insert_pizza(handle, row)

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

def main():
    print("Starting seed process")

    object_client, provider = get_oci_clients()
    
    upload_assets(object_client)

    handle = create_nosql_handle(provider)
    load_pizzas(handle)
    handle.close()

    print("Seed completed successfully")

if __name__ == "__main__":
    main()