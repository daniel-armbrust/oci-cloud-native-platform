#
# vcn-fw-int/vcn.tf
#

resource "oci_core_vcn" "vcn-fw-int" {
    compartment_id = var.compartment_id
    cidr_blocks = ["${var.vcn_cidr}"]
    ipv6private_cidr_blocks = ["${var.vcn_ipv6_cidr}"]
    is_ipv6enabled = true
    is_oracle_gua_allocation_enabled = false
    display_name = "vcn-fw-int"
    dns_label = "vcnfwint"
}