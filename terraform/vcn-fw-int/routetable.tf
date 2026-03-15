#
# vcn-fw-int/routetable.tf
#

# Route Table - Sub-rede Privada #1 (subnpub-1)
resource "oci_core_route_table" "rt_subnprv-1" {   
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-fw-int.id
    display_name = "rt_subnprv-1"   

    # NAT Gateway IPv4
    route_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        network_entity_id = oci_core_nat_gateway.ngw.id
    }

    # DRG VCN-OKE IPv4
    route_rules {
        destination = var.vcn-oke_cidr
        destination_type = "CIDR_BLOCK"
        network_entity_id = var.drg_id
    }    

    # Service Gateway
    route_rules {
        destination = var.sgw_all_oci_services_dst
        destination_type = "SERVICE_CIDR_BLOCK"        
        network_entity_id = oci_core_service_gateway.sgw.id        
    }
}

# VCN Route Table - TO-FIREWALL
resource "oci_core_route_table" "vcn-fw-int_rt" {   
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-fw-int.id
    display_name = "vcn-fw-int_rt"

    # Rota para o NLB do Firewall Interno IPv4
    route_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"   
        network_entity_id = var.nlb_fw-int_ip_id
    }
}