#
# vcn-fw-int/output.tf
#

output "vcn_id" {
    value = oci_core_vcn.vcn-fw-int.id
}

output "subnprv-1_id" {
    value = oci_core_subnet.subnprv-1.id
}

output "drg-attch_id" {
    value = oci_core_drg_attachment.drg-interno-attch_vcn-fw-int.id
}