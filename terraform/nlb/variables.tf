#
# nlb/variables.tf
#

variable "compartment_id" {
    description = "Compartimento raiz onde os recursos serão criados"
    type = string  
}

#------------------------#
# NLB - Firewall Externo #
#------------------------#

variable "firewall-1_ext_ip" {
    description = "Endereço IP do Firewall Externo #1"
    type = string
}

variable "firewall-2_ext_ip" {
    description = "Endereço IP do Firewall Externo #2"
    type = string
}

variable "nlb_fw-ext_ip" {
    description = "Endereço IP do NLB que atende o Firewall Externo"
    type = string
}

variable "vcn-fw-ext_subnprv-1_id" {
    description = "ID da Sub-rede do Firewall Externo"
    type = string
}

#------------------------#
# NLB - Firewall Interno #
#------------------------#

variable "firewall-1_int_ip" {
    description = "Endereço IP do Firewall Interno #1"
    type = string
}

variable "firewall-2_int_ip" {
    description = "Endereço IP do Firewall Interno #2"
    type = string
}

variable "nlb_fw-int_ip" {
    description = "Endereço IP do NLB que atende o Firewall Interno"
    type = string
}

variable "nlb_fw-int_ipv6" {
    description = "Endereço IPv6 do NLB que atende o Firewall Interno"
    type = string
}

variable "vcn-fw-int_subnprv-1_id" {
    description = "ID da Sub-rede do Firewall Interno"
    type = string
}