#
# vcn-oke/vcn.tf
#

resource "oci_core_vcn" "vcn-oke" {
    compartment_id = var.compartment_id
    cidr_blocks = ["${var.vcn_cidr}"]
    ipv6private_cidr_blocks = ["${var.vcn_ipv6_cidr}"]
    is_ipv6enabled = true
    display_name = "vcn-oke"
    dns_label = "vcnwrknodes"
}