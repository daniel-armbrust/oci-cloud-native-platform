#
# vcn-publica/variables.tf
#

variable "compartment_id" {
    description = "Compartimento raiz onde os recursos serão criados."
    type = string  
}

variable "vcn_cidr" {
    description = "Prefixo IPv4 em notação CIDR"
    type = string
}

variable "subnpub-1_cidr" {
    description = "Prefixo IPv4 da Sub-rede Pública"
    type = string
}

variable "meu_ip-publico" {
    description = "Meu endereço IP Público"
    type = string
}

variable "drg_id" {
    description = "OCID do DRG"
    type = string  
}