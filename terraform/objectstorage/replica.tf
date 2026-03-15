#
# objectstorage/replica.tf
#

resource "oci_objectstorage_replication_policy" "objectstorage_replication_policy" {
  count = var.replica_region != null ? 1 : 0

  bucket                  = var.bucket_name
  destination_bucket_name = var.replica_bucket_name
  destination_region_name = var.replica_region
  name                    = "REPLICA_${var.bucket_name}_${var.replica_bucket_name}"
  namespace               = var.namespace
}