#
# nosql/output.tf
#

output "id" {
    description = "ID da tabela NoSQL"
    value = oci_nosql_table.oci_nosql_table.id
}