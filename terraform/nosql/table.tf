#
# nosql/table.tf
#

resource "oci_nosql_table" "oci_nosql_table" {
    compartment_id = var.compartment_id    
    name = var.table_name
    ddl_statement = var.ddl
    is_auto_reclaimable = var.is_auto_reclaimable

    table_limits {
        max_read_units = var.max_read_units
        max_write_units = var.max_write_units
        max_storage_in_gbs = var.max_storage_in_gbs
        capacity_mode = var.capacity_mode
    }
}