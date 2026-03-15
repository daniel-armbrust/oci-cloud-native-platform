#
# vcn-oke/output.tf
#

output "vcn_id" {
    value = oci_core_vcn.vcn-oke.id
}

output "subnpub-lb_id" {
    value = oci_core_subnet.subnpub-lb.id
}

output "subnprv-vm_id" {
    value = oci_core_subnet.subnprv-vm.id
}

output "subnprv-pod_id" {
    value = oci_core_subnet.subnprv-pod.id
}

output "drg-attch_id" {
    value = oci_core_drg_attachment.drg-interno-attch_vcn-oke.id
}