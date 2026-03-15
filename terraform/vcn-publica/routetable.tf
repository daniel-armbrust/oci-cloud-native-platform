#
# vcn-publica/routetable.tf
#

# Route Table - Sub-rede Publica #1 (subnpub-1)
resource "oci_core_route_table" "rt_subnpub-1" {   
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-publica.id
    display_name = "rt_subnpub-1"   

    # Internet Gateway IPv4
    route_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"        
        network_entity_id = oci_core_internet_gateway.igw.id        
    }

    # Internet Gateway IPv6
    route_rules {
        destination = "::/0"
        destination_type = "CIDR_BLOCK"        
        network_entity_id = oci_core_internet_gateway.igw.id
    }
}