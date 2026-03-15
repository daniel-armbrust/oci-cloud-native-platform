#
# objectstorage/bucket.tf
#

resource "oci_objectstorage_bucket" "objectstorage_bucket" {
  compartment_id = var.compartment_id
  namespace      = var.namespace
  name           = var.bucket_name
  access_type    = var.access_type
}