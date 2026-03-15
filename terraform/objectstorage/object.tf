#
# objectstorage/object.tf
#

resource "oci_objectstorage_object" "bucket_object" {
  for_each = toset(var.file_list)

  bucket    = oci_objectstorage_bucket.objectstorage_bucket.name
  namespace = var.namespace
  object    = basename(each.value)
  source    = each.value
}
