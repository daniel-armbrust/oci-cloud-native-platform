#
# vcn-fw-ext/subnet.tf
#

# Sub-rede Privada #1 (subnprv-1)
resource "oci_core_subnet" "subnprv-1" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-fw-ext.id
    dhcp_options_id = oci_core_dhcp_options.dhcp-options.id
    route_table_id = oci_core_route_table.rt_subnprv-1.id
    security_list_ids = [oci_core_security_list.secl-1_subnprv-1.id]

    display_name = "subnprv-1"
    dns_label = "subnprv1"
    cidr_block = "${var.subnprv-1_cidr}"
    ipv6cidr_block = "${var.subnprv-1_ipv6_cidr}"
    
    prohibit_public_ip_on_vnic = true
}