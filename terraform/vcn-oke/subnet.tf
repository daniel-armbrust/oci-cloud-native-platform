#
# vcn-oke/subnet.tf
#

# Sub-rede Pública dos Load Balancers
resource "oci_core_subnet" "subnpub-lb" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    dhcp_options_id = oci_core_dhcp_options.dhcp-options.id
    route_table_id = oci_core_route_table.rt_subnpub-lb.id
    security_list_ids = [oci_core_security_list.secl-1_subnpub-lb.id]

    display_name = "subnpub-lb"
    dns_label = "subnpublb"
    cidr_block = "${var.subnpub-lb_cidr}"
    
    prohibit_public_ip_on_vnic = false
}

# Sub-rede Privada das Máquinas Virtuais
resource "oci_core_subnet" "subnprv-vm" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    dhcp_options_id = oci_core_dhcp_options.dhcp-options.id
    route_table_id = oci_core_route_table.rt_subnprv-vm.id
    security_list_ids = [oci_core_security_list.secl-1_subnprv-vm.id]

    display_name = "subnprv-vm"
    dns_label = "subnprvvm"
    cidr_block = "${var.subnprv-vm_cidr}"
    ipv6cidr_block = "${var.subnprv-vm_ipv6_cidr}"

    prohibit_public_ip_on_vnic = true
}

# Sub-rede Privada dos PODs
resource "oci_core_subnet" "subnprv-pod" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    dhcp_options_id = oci_core_dhcp_options.dhcp-options.id
    route_table_id = oci_core_route_table.rt_subnprv-pod.id
    security_list_ids = [oci_core_security_list.secl-1_subnprv-pod.id]

    display_name = "subnprv-pod"
    dns_label = "subnprvpod"
    cidr_block = "${var.subnprv-pod_cidr}"
    ipv6cidr_block = "${var.subnprv-pod_ipv6_cidr}"

    prohibit_public_ip_on_vnic = true
}