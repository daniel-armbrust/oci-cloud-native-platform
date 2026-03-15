#
# vcn-oke/variables.tf
#

variable "compartment_id" {
    description = "Compartimento raiz onde os recursos serão criados"
    type = string  
}

variable "drg_id" {
    description = "OCID do DRG"
    type = string  
}

variable "drg-interno-attch_vcn-fw-int_id" {
    description = "DRG-INTERNO VCN-FW-INT Attachment ID"
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

variable "subnpub-lb_cidr" {
    description = "Prefixo IPv4 da Sub-rede Pública dos Load Balancers"
    type = string
}

variable "subnprv-vm_cidr" {
    description = "Prefixo IPv4 da Sub-rede Privada das Máquinas Virtuais"
    type = string
}

variable "subnprv-vm_ipv6_cidr" {
    description = "Prefixo IPv6 da Sub-rede Privada das Máquinas Virtuais"
    type = string
}

variable "subnprv-pod_cidr" {
    description = "Prefixo IPv4 da Sub-rede Privada dos PODs"
    type = string
}

variable "subnprv-pod_ipv6_cidr" {
    description = "Prefixo IPv6 da Sub-rede Privada dos PODs"
    type = string
}

variable "meu_ip-publico" {
    description = "Meu endereço IP Público"
    type = string
}