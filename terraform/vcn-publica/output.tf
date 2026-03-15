#
# vcn-publica/output.tf
#

output "vcn_id" {
    value = oci_core_vcn.vcn-publica.id
}

output "subnpub-1_id" {
    value = oci_core_subnet.subnpub-1.id
}