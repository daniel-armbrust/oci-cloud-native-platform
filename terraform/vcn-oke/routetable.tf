#
# vcn-oke/routetable.tf
#

# Route Table - Sub-rede Pública dos Load Balancers
resource "oci_core_route_table" "rt_subnpub-lb" {   
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "rt_subnpub-lb"   

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

# Route Table - Sub-rede Privada das Máquinas Virtuais
resource "oci_core_route_table" "rt_subnprv-vm" {   
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "rt_subnprv-vm"   

    # Service Gateway
    route_rules {
        destination = var.sgw_all_oci_services_dst
        destination_type = "SERVICE_CIDR_BLOCK"        
        network_entity_id = oci_core_service_gateway.sgw.id        
    }

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

# Route Table - Sub-rede Privada dos PODs
resource "oci_core_route_table" "rt_subnprv-pod" {   
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "rt_subnprv-pod"   

    # Service Gateway
    route_rules {
        destination = var.sgw_all_oci_services_dst
        destination_type = "SERVICE_CIDR_BLOCK"        
        network_entity_id = oci_core_service_gateway.sgw.id        
    }

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