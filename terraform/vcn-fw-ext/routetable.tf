#
# vcn-fw-ext/routetable.tf
#

# Route Table - Sub-rede Privada #1 (subnpub-1)
resource "oci_core_route_table" "rt_subnprv-1" {   
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-fw-ext.id
    display_name = "rt_subnprv-1"   

    # DRG IPv4
    route_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        network_entity_id = var.drg_id     
    }

    # DRG IPv6
    route_rules {
        destination = "::/0"
        destination_type = "CIDR_BLOCK"
        network_entity_id = var.drg_id
    }
}