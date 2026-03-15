import os
from functools import lru_cache
from urllib.parse import quote

import oci
import requests
from flask import Flask, jsonify, render_template


def create_app():
    app = Flask(__name__)

    app.config.update(
        ENVIRONMENT=os.getenv("ENVIRONMENT", "dev"),
        PIZZA_API_BASE_URL=os.getenv("PIZZA_API_BASE_URL", "http://pizza-service:8080"),
        AUTH_API_BASE_URL=os.getenv("AUTH_API_BASE_URL", "http://localhost:8084"),
        OBJECT_STORAGE_BUCKET=os.getenv("BUCKET_PIZZAS_IMG", "pizzas-img"),
        OBJECT_STORAGE_NAMESPACE=os.getenv("OBJECT_STORAGE_NAMESPACE", "").strip(),
        OCI_REGION=os.getenv("OCI_REGION", "").strip(),
        COMPARTMENT_ID=os.getenv("COMPARTMENT_ID", "").strip(),
    )

    @app.get("/")
    def home():
        return render_template(
            "main_home.html",
            apiHost=app.config["PIZZA_API_BASE_URL"].rstrip("/"),
            pizzaImageBaseUrl=get_pizza_image_base_url(app),
        )

    @app.get("/health")
    def health():
        return jsonify({"status": "ok"})

    @app.get("/login")
    def login():
        return render_template(
            "login.html",
            apiHost=app.config["PIZZA_API_BASE_URL"].rstrip("/"),
            authApiHost=app.config["AUTH_API_BASE_URL"].rstrip("/"),
            pizzaImageBaseUrl=get_pizza_image_base_url(app),
        )

    @app.get("/api/pizzas")
    def list_pizzas():
        payload = fetch_pizzas(app)
        return jsonify(payload), 200 if payload["status"] == "success" else 502

    return app


def fetch_pizzas(app):
    base_url = app.config["PIZZA_API_BASE_URL"].rstrip("/")

    try:
        response = requests.get(f"{base_url}/pizzas", timeout=15)
        response.raise_for_status()
        payload = response.json()
    except requests.RequestException as exc:
        app.logger.exception("Failed to fetch pizzas from API")
        return {"status": "fail", "message": f"Pizza API unavailable: {exc}"}

    pizzas = payload.get("data", [])

    if payload.get("status") != "success" or not isinstance(pizzas, list):
        return {"status": "fail", "message": "Invalid payload from pizza API"}

    try:
        region = get_oci_region(app)
        namespace = get_object_storage_namespace(app, region)
    except RuntimeError as exc:
        app.logger.exception("Failed to determine Object Storage location")
        return {"status": "fail", "message": str(exc)}

    bucket = app.config["OBJECT_STORAGE_BUCKET"]

    enriched = []
    for pizza in pizzas:
        item = dict(pizza)
        image_name = item.get("image_url", "")
        item["image_url"] = build_image_url(region, namespace, bucket, image_name)
        enriched.append(item)

    return {"status": "success", "data": enriched}


def build_image_url(region, namespace, bucket, image_name):
    if not image_name:
        return ""

    return (
        f"https://objectstorage.{region}.oraclecloud.com"
        f"/n/{namespace}/b/{bucket}/o/{quote(image_name)}"
    )


def get_pizza_image_base_url(app):
    region = app.config["OCI_REGION"] or cached_dev_region()
    namespace = app.config["OBJECT_STORAGE_NAMESPACE"]
    bucket = app.config["OBJECT_STORAGE_BUCKET"]

    if not region or not namespace or not bucket:
        return ""

    return (
        f"https://objectstorage.{region}.oraclecloud.com"
        f"/n/{namespace}/b/{bucket}/o"
    )


@lru_cache(maxsize=1)
def cached_dev_region():
    return "sa-saopaulo-1"


def get_oci_region(app):
    if app.config["ENVIRONMENT"].lower() == "dev":
        return cached_dev_region()

    region = detect_region_with_sdk(app)
    if region:
        return region

    configured_region = app.config["OCI_REGION"]
    if configured_region:
        app.logger.warning("Falling back to OCI_REGION because SDK region detection failed")
        return configured_region

    raise RuntimeError("Unable to determine OCI region")


def get_object_storage_namespace(app, region):
    configured_namespace = app.config["OBJECT_STORAGE_NAMESPACE"]
    if configured_namespace:
        return configured_namespace

    if app.config["ENVIRONMENT"].lower() == "dev":
        raise RuntimeError("OBJECT_STORAGE_NAMESPACE must be defined in development")

    client = get_object_storage_client(app, region)
    compartment_id = app.config["COMPARTMENT_ID"] or None
    namespace = client.get_namespace(compartment_id=compartment_id).data
    if namespace:
        return namespace

    raise RuntimeError("Unable to determine Object Storage namespace")


def detect_region_with_sdk(app):
    signer = get_oci_signer(app)
    signer_region = getattr(signer, "region", None)
    if signer_region:
        return signer_region

    rp_region = os.getenv("OCI_RESOURCE_PRINCIPAL_REGION", "").strip()
    if rp_region:
        return rp_region

    return None


@lru_cache(maxsize=1)
def create_prod_signer():
    if os.getenv("OCI_RESOURCE_PRINCIPAL_VERSION"):
        return oci.auth.signers.get_resource_principals_signer()

    return oci.auth.signers.InstancePrincipalsSecurityTokenSigner()


def get_oci_signer(app):
    if app.config["ENVIRONMENT"].lower() == "dev":
        return None

    return create_prod_signer()


def get_object_storage_client(app, region):
    signer = get_oci_signer(app)
    if signer is None:
        raise RuntimeError("OCI signer unavailable outside development mode")

    return oci.object_storage.ObjectStorageClient({"region": region}, signer=signer)


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
