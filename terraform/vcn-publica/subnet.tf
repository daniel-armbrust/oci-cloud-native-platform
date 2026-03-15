#
# vcn-publica/subnet.tf
#

# Sub-rede Publica #1 (subnpub-1)
resource "oci_core_subnet" "subnpub-1" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-publica.id
    dhcp_options_id = oci_core_dhcp_options.dhcp-options.id
    route_table_id = oci_core_route_table.rt_subnpub-1.id
    security_list_ids = [oci_core_security_list.secl-1_subnpub-1.id]

    display_name = "subnpub-1"
    dns_label = "subnpub1"
    cidr_block = "${var.subnpub-1_cidr}"
    
    prohibit_public_ip_on_vnic = false
}