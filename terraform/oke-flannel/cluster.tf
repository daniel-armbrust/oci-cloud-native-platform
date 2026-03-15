#
# oke/cluster.tf
#

resource "oci_containerengine_cluster" "oke_cluster" {
    count = var.create_cluster ? 1 : 0
    
    compartment_id = var.compartment_id
    kubernetes_version = var.k8s_master_version
    name = var.name
    vcn_id = var.vcn_id

    cluster_pod_network_options {
       cni_type = "FLANNEL_OVERLAY"
    }
    
    endpoint_config {
        is_public_ip_enabled = var.kube-api_pubip_enable
        subnet_id = var.kube-api_subnet_id
    }

    options {
        kubernetes_network_config {
            pods_cidr = var.pods_cidr
            services_cidr = var.services_cidr
        }

        service_lb_subnet_ids = var.lb_subnet_ids
    }

    type = var.type
}