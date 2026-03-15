#
# vcn-fw-ext/variables.tf
#

variable "compartment_id" {
    description = "Compartimento raiz onde os recursos serão criados."
    type = string  
}

variable "drg_id" {
    description = "OCID do DRG"
    type = string  
}

variable "sgw_all_oci_services" {
    description = "All Services In Oracle Services Network"
    type = string
}

variable "sgw_all_oci_services_dst" {
    description = "All Destination Services In Oracle Services Network"
    type = string
}

variable "vcn_cidr" {
    description = "Prefixo IPv4 em notação CIDR"
    type = string
}

variable "vcn_ipv6_cidr" {
    description = "Lista de Prefixos IPv6"
    type = string
}

variable "subnprv-1_cidr" {
    description = "Prefixo IPv4 da Sub-rede Privada"
    type = string
}

variable "subnprv-1_ipv6_cidr" {
    description = "Prefixo IPv6 da Sub-rede Privada"
    type = string
}