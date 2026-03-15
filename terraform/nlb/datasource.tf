#
# nlb/datasource.tf
#

#------------------------#
# NLB - Firewall Externo #
#------------------------#

data "oci_core_private_ips" "nlb_fw-ext-1_private-ip" {    
    ip_address = var.nlb_fw-ext_ip  
    subnet_id = var.vcn-fw-ext_subnprv-1_id
    ip_state = "AVAILABLE"

    depends_on = [
        oci_network_load_balancer_network_load_balancer.nlb_fw-ext
    ]    
}

data "oci_core_private_ips" "nlb_fw-ext_private-ip" {
    ip_address = var.nlb_fw-ext_ip 
    ip_state = "AVAILABLE"
    subnet_id = var.vcn-fw-ext_subnprv-1_id

    depends_on = [
        oci_network_load_balancer_network_load_balancer.nlb_fw-ext
    ] 
}

#------------------------#
# NLB - Firewall Interno #
#------------------------#

data "oci_core_private_ips" "nlb_fw-int-1_private-ip" {    
    ip_address = var.nlb_fw-int_ip  
    subnet_id = var.vcn-fw-int_subnprv-1_id
    ip_state = "AVAILABLE"

    depends_on = [
        oci_network_load_balancer_network_load_balancer.nlb_fw-int
    ]    
}

# data "oci_core_private_ips" "nlb_fw-int-1_private-ipv6" {    
#     ip_address = var.nlb_fw-int_ipv6 
#     subnet_id = var.vcn-fw-int_subnprv-1_id
#     ip_state = "AVAILABLE"

#     depends_on = [
#         oci_network_load_balancer_network_load_balancer.nlb_fw-int
#     ]    
# }

data "oci_core_private_ips" "nlb_fw-int_private-ip" {
    ip_address = var.nlb_fw-int_ip
    ip_state = "AVAILABLE"
    subnet_id = var.vcn-fw-int_subnprv-1_id

    depends_on = [
        oci_network_load_balancer_listener.nlb_fw-int_listener
    ]
}

# data "oci_core_private_ips" "nlb_fw-int_private-ipv6" {
#     ip_address = var.nlb_fw-int_ipv6
#     ip_state = "AVAILABLE"
#     subnet_id = var.vcn-fw-int_subnprv-1_id

#     depends_on = [
#         oci_network_load_balancer_listener.nlb_fw-int_listener
#     ]
# }