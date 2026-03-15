#
# vcn-publica/securitylist.tf
#

# Security List - Sub-rede Publica
resource "oci_core_security_list" "secl-1_subnpub-1" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-publica.id
    display_name = "secl-1_subnpub-1"

    # IPv4
    egress_security_rules {
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
        protocol = "all"
        stateless = false
    }

    ingress_security_rules {
        source = "${var.meu_ip-publico}"
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
}