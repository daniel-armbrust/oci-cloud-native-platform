#
# datasource.tf
#

#
# https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/objectstorage_namespace
#
data "oci_objectstorage_namespace" "objectstorage_ns" {
    compartment_id = var.tenancy_id
}

data "external" "retora_meu_ip-publico" {
    program = ["bash", "./scripts/get-my-publicip.sh"]
}

data "oci_identity_availability_domains" "gru_ads" {
    provider = oci.gru

    compartment_id = var.tenancy_id
}

data "oci_identity_fault_domains" "gru_fds" {
    provider = oci.gru

    compartment_id = var.tenancy_id
    availability_domain = local.ads["gru_ad1_name"]
}

data "oci_identity_availability_domains" "vcp_ads" {
    provider = oci.vcp

    compartment_id = var.tenancy_id
}

data "oci_identity_fault_domains" "vcp_fds" {
    provider = oci.vcp

    compartment_id = var.tenancy_id
    availability_domain = local.ads["vcp_ad1_name"]
}

data "oci_core_services" "gru_all_oci_services" {
    provider = oci.gru

    filter {
       name   = "name"
       values = ["All .* Services In Oracle Services Network"]
       regex  = true
    }
}

data "oci_core_services" "vcp_all_oci_services" {
    provider = oci.vcp
    
    filter {
       name   = "name"
       values = ["All .* Services In Oracle Services Network"]
       regex  = true
    }
}

#
# GRU DRG-INTERNO VCN-FW-INT Attachment
#
data "oci_core_drg_attachments" "gru_drg-interno-attch_vcn-fw-int" {
    provider = oci.gru

    compartment_id = var.root_compartment
    attachment_type = "VCN"    
    drg_id = oci_core_drg.gru_drg-interno.id

    // NOTA: Este atributo depende do valor de DISPLAY_NAME do 
    // Attachment da VCN-FW-INTERNO.
    display_name = "drg-attch_vcn-fw-int"

    depends_on = [
        # oci_core_remote_peering_connection.drg-interno_rpc,
        module.gru_vcn-fw-int
    ]
}

#
# VCP DRG-INTERNO VCN-FW-INT Attachment
#
data "oci_core_drg_attachments" "vcp_drg-interno-attch_vcn-fw-int" {
    provider = oci.vcp

    compartment_id = var.root_compartment
    attachment_type = "VCN"    
    drg_id = oci_core_drg.vcp_drg-interno.id

    // NOTA: Este atributo depende do valor de DISPLAY_NAME do 
    // Attachment da VCN-FW-INTERNO.
    display_name = "drg-attch_vcn-fw-int"

    depends_on = [
        # oci_core_remote_peering_connection.drg-interno_rpc,
        module.vcp_vcn-fw-int
    ]
}