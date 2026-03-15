#
# locals.tf
#

locals {
    # Meu endereço IP Público
    meu_ip-publico = data.external.retora_meu_ip-publico.result.meu_ip-publico

    #
    # sa-saopaulo-1
    #
    gru = {
        #------------#
        # VCN-FW-EXT #
        #------------#
        vcn-fw-ext_cidr = "10.80.0.0/16"
        vcn-fw-ext_subnprv-1_cidr = "10.80.30.0/24"
        vcn-fw-ext_subnprv-1_ip-gw = "10.80.30.1"
        vcn-fw-ext_ipv6_cidr = "fd60:1a2b:9900::/48"
        vcn-fw-ext_subnprv-1_ipv6_cidr = "fd60:1a2b:9900:10::/64"
        vcn-fw-ext_subnprv-1_ipv6-gw = "fd60:1a2b:9900:10::1"

        #------------#
        # VCN-FW-INT #
        #------------#
        vcn-fw-int_cidr = "10.70.0.0/16"
        vcn-fw-int_subnprv-1_cidr = "10.70.10.0/24"
        vcn-fw-int_subnprv-1_ip-gw = "10.70.10.1"
        vcn-fw-int_ipv6_cidr = "fd82:44ee:f000::/48"
        vcn-fw-int_subnprv-1_ipv6_cidr = "fd82:44ee:f000:10::/64"
        vcn-fw-int_subnprv-1_ipv6-gw = "fd82:44ee:f000:10::1"

        #-------------#
        # VCN-PUBLICA #
        #-------------#
        vcn-publica_cidr = "10.30.0.0/16"
        vcn-publica_subnpub-1_cidr = "10.30.10.0/24"
        vcn-publica_ipv6_cidr = "fd55:77cc:8d00::/48"
        vcn-publica_subnpub-1_ipv6_cidr = "fd55:77cc:8d00:10::/64"

        #---------#
        # VCN-OKE #
        #---------#
        vcn-oke_cidr = "10.20.0.0/16"
        vcn-oke_ipv6_cidr = "fd91:ab42:1200::/48"
        
        # Subnet - Load Balancer Network
        vcn-oke_subnpub-lb_cidr = "10.20.10.0/24"   
           
        # Subnet - Virtual Machines Network
        vcn-oke_subnprv-vm_cidr = "10.20.20.0/24"   
        vcn-oke_subnprv-vm_ipv6_cidr = "fd91:ab42:1200:20::/64"     

        # Subnet - PODs Network
        vcn-oke_subnprv-pod_cidr = "10.20.30.0/24"      
        vcn-oke_subnprv-pod_ipv6_cidr = "fd91:ab42:1200:30::/64"   

        #-----#
        # OKE #
        #-----#
        k8s_master_version = "v1.31.10"

        #---------------------#
        # Firewall Externo #1 #
        #---------------------#
        firewall-1_ext_ip = "10.80.30.40"
        firewall-1_ext_ipv6 = "fd60:1a2b:9900:10::40"

        #---------------------#
        # Firewall Externo #2 #
        #---------------------#
        firewall-2_ext_ip = "10.80.30.41"
        firewall-2_ext_ipv6 = "fd60:1a2b:9900:10::41"

        #---------------------#
        # Firewall Interno #1 #
        #---------------------#
        firewall-1_int_ip = "10.70.10.20"
        firewall-1_int_ipv6 = "fd82:44ee:f000:10::20"

        #---------------------#
        # Firewall Interno #2 #
        #---------------------#
        firewall-2_int_ip = "10.70.10.21"
        firewall-2_int_ipv6 = "fd82:44ee:f000:10::21"

        #-----------------------#
        # Network Load Balancer #
        #-----------------------#
        nlb_fw-ext_ip = "10.80.30.100"
        nlb_fw-int_ip = "10.70.10.100"   
        nlb_fw-int_ipv6 = "fd82:44ee:f000:10::100"     

        # Oracle Linux 9.7
        oracle-linux-97-arm_id = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaktgc5bmkbfbkkecwllnrzlekbihf65mrm7ciwptiordmuvsjqbcq" 

        # OKE 1.31.10 - Oracle Linux 8.10 ARM
        oke-13110-ol810-arm_id = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaag5bs7wghnwvl6cdnqrxmq7wgwwt2n6paxl43dc2jzl5rih3ircwa"
    } 

    #
    # sa-vinhedo-1
    #
    vcp = {
        #------------#
        # VCN-FW-EXT #
        #------------#
        vcn-fw-ext_cidr = "172.16.0.0/16"
        vcn-fw-ext_subnprv-1_cidr = "172.16.30.0/24"
        vcn-fw-ext_subnprv-1_ip-gw = "172.16.30.1"
        vcn-fw-ext_ipv6_cidr = "fd7a:3c2e:19ab::/48"
        vcn-fw-ext_subnprv-1_ipv6_cidr = "fd7a:3c2e:19ab:0000::/64"
        vcn-fw-ext_subnprv-1_ipv6-gw = "fd7a:3c2e:19ab:0::1"

        #------------#
        # VCN-FW-INT #
        #------------#
        vcn-fw-int_cidr = "172.17.0.0/16"
        vcn-fw-int_subnprv-1_cidr = "172.17.10.0/24"
        vcn-fw-int_subnprv-1_ip-gw = "172.17.10.1"
        vcn-fw-int_ipv6_cidr = "fd91:74d0:5e22::/48"
        vcn-fw-int_subnprv-1_ipv6_cidr = "fd91:74d0:5e22:0000::/64"
        vcn-fw-int_subnprv-1_ipv6-gw = "fd91:74d0:5e22:0::1"

        #-------------#
        # VCN-PUBLICA #
        #-------------#
        vcn-publica_cidr = "172.18.0.0/16"
        vcn-publica_subnpub-1_cidr = "172.18.10.0/24"
        vcn-publica_ipv6_cidr = "fd55:77cc:8d00::/48"
        vcn-publica_subnpub-1_ipv6_cidr = "fd55:77cc:8d00:10::/64"

        #---------#
        # VCN-OKE #
        #---------#
        vcn-oke_cidr = "172.19.0.0/16"
        vcn-oke_ipv6_cidr = "fd3f:9012:aa00::/48"
        
        # Subnet - Load Balancer Network
        vcn-oke_subnpub-lb_cidr = "172.19.10.0/24"   
           
        # Subnet - Virtual Machines Network
        vcn-oke_subnprv-vm_cidr = "172.19.20.0/24"   
        vcn-oke_subnprv-vm_ipv6_cidr = "fd3f:9012:aa00:20::/64"
        
        # Subnet - PODs Network
        vcn-oke_subnprv-pod_cidr = "172.19.30.0/24"      
        vcn-oke_subnprv-pod_ipv6_cidr = "fd3f:9012:aa00:30::/64"   

        #-----#
        # OKE #
        #-----#

        #---------------------#
        # Firewall Externo #1 #
        #---------------------#
        firewall-1_ext_ip = "172.16.30.40"
        firewall-1_ext_ipv6 = "fd7a:3c2e:19ab:0::40"

        #---------------------#
        # Firewall Externo #2 #
        #---------------------#
        firewall-2_ext_ip = "172.16.30.41"
        firewall-2_ext_ipv6 = "fd7a:3c2e:19ab:0::41"

        #---------------------#
        # Firewall Interno #1 #
        #---------------------#
        firewall-1_int_ip = "172.17.10.20"
        firewall-1_int_ipv6 = "fd91:74d0:5e22:0::20"

        #---------------------#
        # Firewall Interno #2 #
        #---------------------#
        firewall-2_int_ip = "172.17.10.21"
        firewall-2_int_ipv6 = "fd91:74d0:5e22:0::21"

        #-----------------------#
        # Network Load Balancer #
        #-----------------------#
        nlb_fw-ext_ip = "172.16.30.100"
        nlb_fw-int_ip = "172.17.10.100"
        nlb_fw-int_ipv6 = "fd91:74d0:5e22:0::100"          

        # Oracle Linux 9.7
        oracle-linux-97-arm_id = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaalhlldgc2m2dhcorswrangv5jgbfxrdbjnie5qa27awu352z3d7qq"

        # OKE 1.31.10 - Oracle Linux 8.10 ARM
        oke-13110-ol810-arm_id = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaavbimll7xjhyxha2ucrdmrvhjzmgbdeokonj5h5bunbw7mpwowxea"      
    }

    # Availability Domains
    ads = {
      gru_ad1_id = data.oci_identity_availability_domains.gru_ads.availability_domains[0].id
      gru_ad1_name = data.oci_identity_availability_domains.gru_ads.availability_domains[0].name

      vcp_ad1_id = data.oci_identity_availability_domains.vcp_ads.availability_domains[0].id
      vcp_ad1_name = data.oci_identity_availability_domains.vcp_ads.availability_domains[0].name
   }

   # Fault Domains
   fds = {
      # GRU
      gru_fd1_id = data.oci_identity_fault_domains.gru_fds.fault_domains[0].id,
      gru_fd1_name = data.oci_identity_fault_domains.gru_fds.fault_domains[0].name,

      gru_fd2_id = data.oci_identity_fault_domains.gru_fds.fault_domains[1].id,
      gru_fd2_name = data.oci_identity_fault_domains.gru_fds.fault_domains[1].name,

      gru_fd3_id = data.oci_identity_fault_domains.gru_fds.fault_domains[2].id,
      gru_fd3_name = data.oci_identity_fault_domains.gru_fds.fault_domains[2].name          

      # VCP
      vcp_fd1_id = data.oci_identity_fault_domains.vcp_fds.fault_domains[0].id,
      vcp_fd1_name = data.oci_identity_fault_domains.vcp_fds.fault_domains[0].name,

      vcp_fd2_id = data.oci_identity_fault_domains.vcp_fds.fault_domains[1].id,
      vcp_fd2_name = data.oci_identity_fault_domains.vcp_fds.fault_domains[1].name,

      vcp_fd3_id = data.oci_identity_fault_domains.vcp_fds.fault_domains[2].id,
      vcp_fd3_name = data.oci_identity_fault_domains.vcp_fds.fault_domains[2].name

   }

   # Service Gateway
   gru_all_oci_services = lookup(data.oci_core_services.gru_all_oci_services.services[0], "id")
   gru_oci_services_cidr_block = lookup(data.oci_core_services.gru_all_oci_services.services[0], "cidr_block")
   
   vcp_all_oci_services = lookup(data.oci_core_services.vcp_all_oci_services.services[0], "id")
   vcp_oci_services_cidr_block = lookup(data.oci_core_services.vcp_all_oci_services.services[0], "cidr_block")      
}