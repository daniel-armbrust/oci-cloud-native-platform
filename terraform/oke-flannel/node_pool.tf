#
# oke/worker.tf
#

resource "oci_containerengine_node_pool" "node_pool" {
  for_each = var.create_cluster ? {
    for np in var.node_pools : np.name => np
  } : {}
  
  compartment_id = var.compartment_id

  cluster_id = oci_containerengine_cluster.oke_cluster[0].id
  kubernetes_version = each.value.k8s_worker_version
  name = each.value.name
  node_shape = each.value.node_shape

  node_config_details {
    size = each.value.total_nodes

    placement_configs {
      availability_domain = each.value.availability_domain
      subnet_id = each.value.subnet_id
    }
  }

  node_shape_config {
    memory_in_gbs = each.value.mem_gbs
    ocpus = each.value.ocpu
  }

  node_source_details {
    image_id    = each.value.os_image_id
    source_type = "IMAGE"
    boot_volume_size_in_gbs = each.value.bootvol_gbs
  }

  ssh_public_key = each.value.sshpub_key

  node_metadata = {
     user_data = base64encode(each.value.init_script)
  }
}
