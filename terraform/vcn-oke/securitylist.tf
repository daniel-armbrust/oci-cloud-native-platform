#
# vcn-oke/securitylist.tf
#

# Security List - Sub-rede Pública dos Load Balancers
resource "oci_core_security_list" "secl-1_subnpub-lb" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "secl-1_subnpub-lb"

    # IPv4
    egress_security_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }
    
    # IPv6
    egress_security_rules {
        destination = "::/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }

    # IPv4
    ingress_security_rules {
        source = "${var.meu_ip-publico}"
        protocol = "all"
        source_type = "CIDR_BLOCK"
        stateless = true
    }

    ingress_security_rules {
        source = var.vcn_cidr
        source_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }

    # IPv6
    ingress_security_rules {
        source = var.vcn_ipv6_cidr
        source_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }
}

# Security List - Sub-rede Privada das Máquinas Virtuais
resource "oci_core_security_list" "secl-1_subnprv-vm" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "secl-1_subnprv-vm"

    # IPv4
    egress_security_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }

    ingress_security_rules {
        source = "0.0.0.0/0"
        protocol = "all"
        source_type = "CIDR_BLOCK"
        stateless = true
    }

    # IPv6
    egress_security_rules {
        destination = "::/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }

    ingress_security_rules {
        source = "::/0"
        source_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }
}

# Security List - Sub-rede Privada dos PODs
resource "oci_core_security_list" "secl-1_subnprv-pod" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "secl-1_subnprv-pod"

    # IPv4
    egress_security_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }

    ingress_security_rules {
        source = "0.0.0.0/0"
        protocol = "all"
        source_type = "CIDR_BLOCK"
        stateless = true
    }

    # IPv6
    egress_security_rules {
        destination = "::/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }

    ingress_security_rules {
        source = "::/0"
        source_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = true
    }
}