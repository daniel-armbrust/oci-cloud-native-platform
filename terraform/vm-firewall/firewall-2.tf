#
# vm-firewall/firewall-2.tf
#

resource "oci_core_instance" "firewall-2" {
    compartment_id = var.compartment_id
    availability_domain = var.availability_domain    
    display_name = "firewall-2"

    shape = "VM.Standard.A1.Flex" 

    shape_config {
        baseline_ocpu_utilization = "BASELINE_1_1"
        memory_in_gbs = 4
        ocpus = 3
    }

    source_details {
        source_id = var.os_image_id
        source_type = "image"
        boot_volume_size_in_gbs = 100
    }  

    agent_config {
        is_management_disabled = false
        is_monitoring_disabled = false

        plugins_config {
            desired_state = "ENABLED"
            name = "Bastion"
        }
    }

    metadata = {
        # ssh_authorized_keys = file("../ssh-keys/ssh-key.pub")
        # user_data = base64encode(file("../scripts/firewall-init.sh"))
        ssh_authorized_keys = var.sshpub_key
        user_data = var.os_script_init
    }

    extended_metadata = {
        # Firewall #2 IPs
        "firewall-int-ip" = "${var.firewall-2_int_ip}"
        "firewall-int-ipv6" = "${var.firewall-2_int_ipv6}"
        "firewall-ext-ip" = "${var.firewall-2_ext_ip}"
        "firewall-ext-ipv6" = "${var.firewall-2_ext_ipv6}"

        # vcn-fw-ext
        "vcn-fw-ext-cidr" = "${var.vcn-fw-ext_cidr}"
        "vcn-fw-ext-ipv6-cidr" = "${var.vcn-fw-ext_ipv6_cidr}"
        "vcn-fw-ext-subnprv1-ip-gw" = "${var.vcn-fw-ext_subnprv-1_ip-gw}" 
        "vcn-fw-ext-subnprv1-ipv6-gw" = "${var.vcn-fw-ext_subnprv-1_ipv6_cidr}" 

        # vcn-fw-int
        "vcn-fw-int-cidr" = "${var.vcn-fw-int_cidr}"
        "vcn-fw-int-ipv6-cidr" = "${var.vcn-fw-int_ipv6_cidr}"
        "vcn-fw-int-subnprv1-ip-gw" = "${var.vcn-fw-int_subnprv-1_ip-gw}" 
        "vcn-fw-int-subnprv1-ipv6-gw" = "${var.vcn-fw-int_subnprv-1_ipv6_cidr}"
    }

    # VNIC vcn-fw-int
    create_vnic_details {
        display_name = "vnic-int"
        hostname_label = "fw2int"
        private_ip = "${var.firewall-2_int_ip}"        
        subnet_id = "${var.vcn-fw-int_subnprv-1_id}"
        skip_source_dest_check = true
        assign_public_ip = false
        
        assign_ipv6ip = true

        ipv6address_ipv6subnet_cidr_pair_details {
           ipv6subnet_cidr = "${var.vcn-fw-int_subnprv-1_ipv6_cidr}"
           ipv6address = "${var.firewall-2_int_ipv6}"
        }
    }
}

# VNIC vcn-fw-ext
resource "oci_core_vnic_attachment" "firewall-2_vnic-ext" {  
    display_name = "vnic-ext"
    instance_id = oci_core_instance.firewall-2.id
      
    create_vnic_details {    
        display_name = "vnic-ext"    
        hostname_label = "fw2ext"
        private_ip = "${var.firewall-2_ext_ip}"   
        subnet_id = "${var.vcn-fw-ext_subnprv-1_id}"
        skip_source_dest_check = true
        assign_public_ip = false
        
        assign_ipv6ip = true

        ipv6address_ipv6subnet_cidr_pair_details {
           ipv6_subnet_cidr = "${var.vcn-fw-ext_subnprv-1_ipv6_cidr}"
           ipv6_address = "${var.firewall-2_ext_ipv6}"
        }
    }       

    depends_on = [
        oci_core_instance.firewall-2
    ]   
}