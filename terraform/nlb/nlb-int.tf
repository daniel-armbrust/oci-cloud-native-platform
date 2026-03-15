#
# nlb/nlb-int.tf
#

resource "oci_network_load_balancer_network_load_balancer" "nlb_fw-int" {
    compartment_id = var.compartment_id

    display_name = "nlb_fw-int"    
    assigned_private_ipv4 = var.nlb_fw-int_ip
    # assigned_ipv6 = var.nlb_fw-int_ipv6
    subnet_id = var.vcn-fw-int_subnprv-1_id    
    
    is_private = true
    is_preserve_source_destination = true
    is_symmetric_hash_enabled = true
}

resource "oci_network_load_balancer_listener" "nlb_fw-int_listener" {
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_fw-int.id

    name = "fw-int_listener"
    default_backend_set_name = "fw-int_backendset"

    ip_version = "IPV4"
    protocol = "ANY"
    port = 0

    depends_on = [
        oci_network_load_balancer_backend_set.nlb_fw-int_backend_set
    ]
}

resource "oci_network_load_balancer_backend_set" "nlb_fw-int_backend_set" {
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_fw-int.id
    
    name = "fw-int_backendset"
    ip_version = "IPV4"
    is_preserve_source = false
    is_instant_failover_enabled = true
    policy = "TWO_TUPLE"

    health_checker {
       protocol = "TCP"
       port = 22
    }  
}

resource "oci_network_load_balancer_backend" "nlb_fw-int-1" {
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_fw-int.id
    
    backend_set_name = "fw-int_backendset"    

    name = "firewall-1"
    ip_address = var.firewall-1_int_ip
    port = 0
    is_backup = false
    is_drain = false
    is_offline = false
    weight = 1

    depends_on = [
        oci_network_load_balancer_backend_set.nlb_fw-int_backend_set
    ]
}

resource "oci_network_load_balancer_backend" "nlb_fw-int-2" {
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_fw-int.id
    
    backend_set_name = "fw-int_backendset"    

    name = "firewall-2"
    ip_address = var.firewall-2_int_ip
    port = 0
    is_backup = false
    is_drain = false
    is_offline = false
    weight = 1

    depends_on = [
        oci_network_load_balancer_backend_set.nlb_fw-int_backend_set
    ]
}