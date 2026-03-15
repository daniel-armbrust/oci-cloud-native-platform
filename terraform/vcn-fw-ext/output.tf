#
# vcn-fw-ext/output.tf
#

output "vcn_id" {
    value = oci_core_vcn.vcn-fw-ext.id
}

output "subnprv-1_id" {
    value = oci_core_subnet.subnprv-1.id
}