#
# vcn-publica/vcn.tf
#

resource "oci_core_vcn" "vcn-publica" {
    compartment_id = var.compartment_id
    cidr_blocks = ["${var.vcn_cidr}"]
    is_ipv6enabled = true
    is_oracle_gua_allocation_enabled = true
    display_name = "vcn-publica"
    dns_label = "vcnpub"
}