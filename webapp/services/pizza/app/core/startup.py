#
# pizza/app/core/startup.py
# 

from app.config import get_object_storage_client, get_settings, get_nosql_handle
from app.services.image_storage_service import ImageStorageService
from app.services.pizza_service import PizzaService

def init_services(app):
    settings = get_settings()
    handle = get_nosql_handle()
    object_storage_client = get_object_storage_client()

    app.state.service = PizzaService(handle, settings)
    app.state.image_storage = ImageStorageService(object_storage_client, settings)
