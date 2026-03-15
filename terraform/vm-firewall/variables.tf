#
# vm-firewall/variables.tf
#

variable "compartment_id" {
    description = "Compartimento raiz onde os recursos serão criados"
    type = string  
}

variable "availability_domain" {
    description = "Nome do Availability Domain"
    type = string
}

variable "os_image_id" {
    description = "OCID da imagem do Sistema Operacional"
    type = string
}

variable "sshpub_key" {
    description = "Chave pública SSH"
    type = string
}

variable "os_script_init" {
    description = "Script de inicilização cloud-init"
    type = string
}

#------------#
# vcn-fw-ext #
#------------#

variable "vcn-fw-ext_cidr" {
    description = "Prefixo IPv4 da VCN-FIREWALL-EXT em notação CIDR"
    type = string 
}

variable "vcn-fw-ext_subnprv-1_ip-gw" {
    description = "Endereço IPv4 do Gateway da Sub-rede privada"
    type = string
}

variable "vcn-fw-ext_ipv6_cidr" {
    description = "Prefixo IPv6 da VCN-FIREWALL-EXT em notação CIDR"
    type = string 
}

variable "vcn-fw-ext_subnprv-1_ipv6_cidr" {
    description = "Prefixo IPv6 da Sub-rede privada VCN-FIREWALL-EXT"
    type = string
}

variable "vcn-fw-ext_subnprv-1_ipv6-gw" {
    description = "Endereço IPv6 do Gateway da Sub-rede privada VCN-FIREWALL-EXT"
    type = string
}

variable "vcn-fw-ext_subnprv-1_id" {
    description = "OCID da Sub-rede privada VCN-FIREWALL-EXT"
    type = string
}

#------------#
# vcn-fw-int #
#------------#

variable "vcn-fw-int_cidr" {
    description = "Prefixo IPv4 da VCN-FIREWALL-INT em notação CIDR"
    type = string 
}

variable "vcn-fw-int_subnprv-1_ip-gw" {
    description = "Endereço IPv4 do Gateway da Sub-rede privada"
    type = string
}

variable "vcn-fw-int_ipv6_cidr" {
    description = "Prefixo IPv6 da VCN-FIREWALL-INT em notação CIDR"
    type = string 
}

variable "vcn-fw-int_subnprv-1_ipv6_cidr" {
    description = "Prefixo IPv6 da Sub-rede privada VCN-FIREWALL-INT"
    type = string
}

variable "vcn-fw-int_subnprv-1_ipv6-gw" {
    description = "Endereço IPv6 do Gateway da Sub-rede privada VCN-FIREWALL-INT"
    type = string
}

variable "vcn-fw-int_subnprv-1_id" {
    description = "OCID da Sub-rede privada VCN-FIREWALL-INT"
    type = string
}

#-------------#
# FIREWALL #1 #
#-------------#

variable "firewall-1_int_ip" {
    description = "Firewall #1 - Endereço IPv4 da VNIC localizada na VCN-FW-INT"
    type = string
}

variable "firewall-1_int_ipv6" {
    description = "Firewall #1 - Endereço IPv6 da VNIC localizada na VCN-FW-INT"
    type = string
}

variable "firewall-1_ext_ip" {
    description = "Firewall #1 - Endereço IPv4 da VNIC localizada na VCN-FW-EXT"
    type = string
}

variable "firewall-1_ext_ipv6" {
    description = "Firewall #1 - Endereço IPv6 da VNIC localizada na VCN-FW-EXT"
    type = string
}

#-------------#
# FIREWALL #2 #
#-------------#

variable "firewall-2_int_ip" {
    description = "Firewall #2 - Endereço IPv4 da VNIC localizada na VCN-FW-INT"
    type = string
}

variable "firewall-2_int_ipv6" {
    description = "Firewall #2 - Endereço IPv6 da VNIC localizada na VCN-FW-INT"
    type = string
}

variable "firewall-2_ext_ip" {
    description = "Firewall #2 - Endereço IPv4 da VNIC localizada na VCN-FW-EXT"
    type = string
}

variable "firewall-2_ext_ipv6" {
    description = "Firewall #2 - Endereço IPv6 da VNIC localizada na VCN-FW-EXT"
    type = string
}