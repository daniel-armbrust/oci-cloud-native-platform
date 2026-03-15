#
# oke/variables.tf
#

variable "compartment_id" {
    description = "ID do compartimento onde os recursos serão criados"
    type = string  
}

variable "create_cluster" {
  description = "Controla se o OKE será criado ou não"
  type = bool
  default = false
}

variable "name" {
    description = "Nome do cluster"
    type = string
}

variable "type" {
    description = "Tipo do cluster (BASIC_CLUSTER ou ENHANCED_CLUSTER)"
    type = string
}

variable "k8s_master_version" {
    description = "Versão kubernetes do Master Node"
    type = string
}

variable "vcn_id" {
    description = "ID da VCN onde o cluster será criado"
    type = string
}

variable "kube-api_pubip_enable" {
    description = "Flag para habilitar IP público ao kube-api"
    type = bool
}

variable "kube-api_subnet_id" {
    description = "ID da sub-rede do kube-api"
    type = string
}

variable "pods_cidr" {
    description = "Bloco CIDR para pods do Kubernetes. Opcional, o padrão é 10.244.0.0/16."
    type = string
    default = "10.244.0.0/16"
}

variable "services_cidr" {
    description = "Bloco CIDR para serviços do Kubernetes. Opcional, o padrão é 10.96.0.0/16."
    type = string
    default = "10.96.0.0/16"
}

variable "lb_subnet_ids" {
    description = "Lista de IDs das sub-redes para Load Balancer"
    type = list
}

variable "node_pools" {
  type = list(object({
        total_nodes = number
        name = string
        k8s_worker_version = string
        availability_domain = string
        subnet_id = string
        os_image_id = string
        node_shape = string
        mem_gbs = number
        ocpu = number
        bootvol_gbs = number
        sshpub_key = string
        init_script = string
  }))
}