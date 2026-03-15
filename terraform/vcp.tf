#
# vcp.tf - sa-vinhedo-1
#

#
# VCN-FW-EXT
#
module "vcp_vcn-fw-ext" {
    source = "./vcn-fw-ext"

    providers = {
       oci = oci.vcp
    }
    
    compartment_id = var.root_compartment
    
    # VCN
    vcn_cidr = local.vcp.vcn-fw-ext_cidr
    vcn_ipv6_cidr = local.vcp.vcn-fw-ext_ipv6_cidr

    # Subnet Privada
    subnprv-1_cidr = local.vcp.vcn-fw-ext_subnprv-1_cidr
    subnprv-1_ipv6_cidr = local.vcp.vcn-fw-ext_subnprv-1_ipv6_cidr

    # DRG
    drg_id = oci_core_drg.vcp_drg-externo.id

    # Service Gateway (ALL SERVICES GRU)
    sgw_all_oci_services = local.vcp_all_oci_services
    sgw_all_oci_services_dst = "all-vcp-services-in-oracle-services-network"
}

#
# VCN-FW-INT
#
module "vcp_vcn-fw-int" {
    source = "./vcn-fw-int"

    providers = {
       oci = oci.vcp
    }
    
    compartment_id = var.root_compartment
    
    # VCN
    vcn_cidr = local.vcp.vcn-fw-int_cidr
    vcn_ipv6_cidr = local.vcp.vcn-fw-int_ipv6_cidr

    # Subnet Privada
    subnprv-1_cidr = local.vcp.vcn-fw-int_subnprv-1_cidr
    subnprv-1_ipv6_cidr = local.vcp.vcn-fw-int_subnprv-1_ipv6_cidr

    # DRG
    drg_id = oci_core_drg.vcp_drg-interno.id

    # Network Load Balancer IP ID
    nlb_fw-int_ip_id = module.vcp_nlb.nlb_fw-int_private-ip_id

    # VCN-OKE
    vcn-oke_cidr = local.vcp.vcn-oke_cidr

    # Service Gateway (ALL SERVICES GRU)
    sgw_all_oci_services = local.vcp_all_oci_services
    sgw_all_oci_services_dst = "all-vcp-services-in-oracle-services-network"
}

#
# VCN-PUBLICA
#
module "vcp_vcn-publica" {
    source = "./vcn-publica"

    providers = {
       oci = oci.vcp
    }
    
    compartment_id = var.root_compartment
    
    vcn_cidr = local.vcp.vcn-publica_cidr
    subnpub-1_cidr = local.vcp.vcn-publica_subnpub-1_cidr
    
    # Meu endereço IP Publico.
    meu_ip-publico = local.meu_ip-publico 

    # DRG
    drg_id = oci_core_drg.vcp_drg-interno.id
}

#
# VCN-OKE
#
module "vcp_vcn-oke" {
    source = "./vcn-oke"

    providers = {
       oci = oci.vcp
    }
    
    compartment_id = var.root_compartment
    
    # VCN
    vcn_cidr = local.vcp.vcn-oke_cidr
    vcn_ipv6_cidr = local.vcp.vcn-oke_ipv6_cidr

    # Subnet - Load Balancer Network
    subnpub-lb_cidr = local.vcp.vcn-oke_subnpub-lb_cidr
    
    # Subnet - Virtual Machines Network
    subnprv-vm_cidr = local.vcp.vcn-oke_subnprv-vm_cidr
    subnprv-vm_ipv6_cidr = local.vcp.vcn-oke_subnprv-vm_ipv6_cidr

    # Subnet - PODs Network
    subnprv-pod_cidr = local.vcp.vcn-oke_subnprv-pod_cidr
    subnprv-pod_ipv6_cidr = local.vcp.vcn-oke_subnprv-pod_ipv6_cidr
    
    # DRG
    drg_id = oci_core_drg.vcp_drg-interno.id
    drg-interno-attch_vcn-fw-int_id = "${data.oci_core_drg_attachments.vcp_drg-interno-attch_vcn-fw-int.drg_attachments[0].id}"

    # Service Gateway (ALL SERVICES GRU)
    sgw_all_oci_services = local.vcp_all_oci_services
    sgw_all_oci_services_dst = "all-vcp-services-in-oracle-services-network"

    # Meu endereço IP Publico.
    meu_ip-publico = local.meu_ip-publico   
}

#
# Firewall VM
#
module "vcp_vm-firewall" {
  source = "./vm-firewall"

  providers = {
    oci = oci.vcp
  }

  compartment_id = var.root_compartment

  # Availability Domain
  availability_domain = local.ads.vcp_ad1_name

  # Oracle Linux Image ID
  os_image_id = local.vcp.oracle-linux-97-arm_id

  sshpub_key = file("${path.module}/ssh-keys/ssh-key.pub")
  os_script_init = base64encode(file("${path.module}/scripts/firewall-init.sh"))

  #------------#
  # VCN-FW-EXT #
  #------------#

  # IPv4
  vcn-fw-ext_cidr = local.vcp.vcn-fw-ext_cidr
  vcn-fw-ext_subnprv-1_ip-gw = local.vcp.vcn-fw-ext_subnprv-1_ip-gw

  # IPv6
  vcn-fw-ext_ipv6_cidr = local.vcp.vcn-fw-ext_ipv6_cidr
  vcn-fw-ext_subnprv-1_ipv6_cidr = local.vcp.vcn-fw-ext_subnprv-1_ipv6_cidr
  vcn-fw-ext_subnprv-1_ipv6-gw = local.vcp.vcn-fw-ext_subnprv-1_ipv6-gw

  # OCID da sub-rede privada "subnprv-1" da VCN "vcn-fw-ext"
  vcn-fw-ext_subnprv-1_id = module.vcp_vcn-fw-ext.subnprv-1_id

  #------------#
  # VCN-FW-INT #
  #------------#

  # IPv4
  vcn-fw-int_cidr = local.vcp.vcn-fw-int_cidr
  vcn-fw-int_subnprv-1_ip-gw = local.vcp.vcn-fw-int_subnprv-1_ip-gw

  # IPv6
  vcn-fw-int_ipv6_cidr = local.vcp.vcn-fw-int_ipv6_cidr
  vcn-fw-int_subnprv-1_ipv6_cidr = local.vcp.vcn-fw-int_subnprv-1_ipv6_cidr
  vcn-fw-int_subnprv-1_ipv6-gw = local.vcp.vcn-fw-int_subnprv-1_ipv6-gw

  # OCID da sub-rede privada "subnprv-1" da VCN "vcn-fw-int"
  vcn-fw-int_subnprv-1_id = module.vcp_vcn-fw-int.subnprv-1_id

  #-------------#
  # VM-FIREWALL #
  #-------------#

  # Firewall #1 
  firewall-1_ext_ip = local.vcp.firewall-1_ext_ip
  firewall-1_ext_ipv6 = local.vcp.firewall-1_ext_ipv6
  firewall-1_int_ip = local.vcp.firewall-1_int_ip
  firewall-1_int_ipv6 = local.vcp.firewall-1_int_ipv6

  # Firewall #2
  firewall-2_ext_ip = local.vcp.firewall-2_ext_ip
  firewall-2_ext_ipv6 = local.vcp.firewall-2_ext_ipv6
  firewall-2_int_ip = local.vcp.firewall-2_int_ip
  firewall-2_int_ipv6 = local.vcp.firewall-2_int_ipv6
}

#
# Network Load Balancer
#
module "vcp_nlb" {
  source = "./nlb"

  providers = {
    oci = oci.vcp
  }

  compartment_id = var.root_compartment

  nlb_fw-int_ip = local.vcp.nlb_fw-int_ip
  nlb_fw-int_ipv6 = local.vcp.nlb_fw-int_ipv6
  nlb_fw-ext_ip = local.vcp.nlb_fw-ext_ip

  vcn-fw-int_subnprv-1_id = module.vcp_vcn-fw-int.subnprv-1_id
  vcn-fw-ext_subnprv-1_id = module.vcp_vcn-fw-ext.subnprv-1_id
       
  # Firewall #1
  firewall-1_int_ip = local.vcp.firewall-1_int_ip
  firewall-1_ext_ip = local.vcp.firewall-1_ext_ip

  # Firewall #2
  firewall-2_int_ip = local.vcp.firewall-2_int_ip
  firewall-2_ext_ip = local.vcp.firewall-2_ext_ip
}

#
# OKE
#
module "vcp_oke-flannel-1" {
  source = "./oke-flannel"
  
  providers = {
    oci = oci.vcp
  }

  # Controla se o cluster será criado ou não
  create_cluster = false

  compartment_id = var.root_compartment

  name = "vcp_oke-1"
  type = "BASIC_CLUSTER"
  k8s_master_version = "v1.31.10"

  vcn_id = module.vcp_vcn-oke.vcn_id

  # kube-api
  kube-api_pubip_enable = true
  kube-api_subnet_id = module.vcp_vcn-oke.subnpub-lb_id
  
  # network
  pods_cidr = "10.244.0.0/16"
  services_cidr = "10.96.0.0/16"

  # load balancer
  lb_subnet_ids = ["${module.vcp_vcn-oke.subnpub-lb_id}"]

  node_pools = [
    {
       total_nodes = 2 

       name = "node-pool-1"       
       k8s_worker_version = "v1.31.10"

       availability_domain = local.ads.vcp_ad1_name
       subnet_id = module.vcp_vcn-oke.subnprv-vm_id
       
       node_shape = "VM.Standard.A1.Flex"
       os_image_id = local.vcp.oke-13110-ol810-arm_id
       sshpub_key = file("${path.module}/ssh-keys/ssh-key.pub") 
       ocpu = 2
       mem_gbs = 4       
       bootvol_gbs = 100  

       init_script = file("${path.module}/scripts/oke-init.sh")          
    }      
  ] 
}

#
# ObjectStorage
#
module "vcp_objectstorage_bucket_pizzas-img" {
    source = "./objectstorage"

    providers = {
       oci = oci.vcp
    }
    
    compartment_id = var.root_compartment
    
    bucket_name = "pizzas-img"
    access_type = "ObjectRead"
    namespace = data.oci_objectstorage_namespace.objectstorage_ns.namespace
}

module "vcp_objectstorage_bucket_scripts-storage" {
    source = "./objectstorage"

    providers = {
       oci = oci.vcp
    }
    
    compartment_id = var.root_compartment
    
    bucket_name = "scripts-storage"
    access_type = "NoPublicAccess"
    namespace = data.oci_objectstorage_namespace.objectstorage_ns.namespace
}