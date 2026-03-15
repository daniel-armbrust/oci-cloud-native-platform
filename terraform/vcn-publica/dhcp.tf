#
# vcn-publica/dhcp.tf
#

# Dhcp Options
resource "oci_core_dhcp_options" "dhcp-options" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-publica.id
    display_name = "dhcp-options"

    options {
        type = "DomainNameServer"
        server_type = "VcnLocalPlusInternet"
    }
}