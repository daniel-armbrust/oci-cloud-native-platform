import mimetypes
import os
import re
import time
import unicodedata


class ImageStorageService:
    def __init__(self, client, settings):
        self.client = client
        self.settings = settings
        self.bucket_name = settings.BUCKET_PIZZAS_IMG
        self.namespace = settings.OBJECT_STORAGE_NAMESPACE.strip() or client.get_namespace().data

    def _slugify(self, value: str) -> str:
        normalized = unicodedata.normalize("NFKD", value or "")
        ascii_value = normalized.encode("ascii", "ignore").decode()
        return re.sub(r"[^a-z0-9]+", "-", ascii_value.lower()).strip("-") or "pizza"

    def _guess_extension(self, filename: str, content_type: str | None) -> str:
        ext = os.path.splitext(filename or "")[1].lower()
        if ext:
            return ext

        guessed = mimetypes.guess_extension(content_type or "")
        if guessed == ".jpe":
            return ".jpg"
        return guessed or ".bin"

    def build_object_name(self, base_name: str, filename: str, content_type: str | None) -> str:
        slug = self._slugify(base_name)
        ext = self._guess_extension(filename, content_type)
        return f"{slug}-{int(time.time() * 1000)}{ext}"

    def upload_image(self, object_name: str, content: bytes, content_type: str | None):
        self.client.put_object(
            namespace_name=self.namespace,
            bucket_name=self.bucket_name,
            object_name=object_name,
            put_object_body=content,
            content_type=content_type or "application/octet-stream",
        )
        return object_name
