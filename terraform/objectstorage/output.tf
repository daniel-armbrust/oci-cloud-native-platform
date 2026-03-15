#
# objectstorage/output.tf
#

output "bucket_name" {
  description = "Nome do Bucket"
  value = oci_objectstorage_bucket.objectstorage_bucket.name
}

output "object_names" {
  description = "Objetos enviados para o bucket"
  value = [for item in oci_objectstorage_object.bucket_object : item.object]
}
