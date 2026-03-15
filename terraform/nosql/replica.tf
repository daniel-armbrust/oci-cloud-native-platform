#
# nosql/replica.tf
#

resource "oci_nosql_table_replica" "nosql_table_replica" {
  count = var.create_replica ? 1 : 0

  region = var.replica_region
  table_name_or_id = var.replica_table_id

  depends_on = [
     oci_nosql_table.oci_nosql_table
  ]
}