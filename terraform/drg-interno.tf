#
# drg-interno.tf
#

resource "oci_core_drg" "gru_drg-interno" { 
    provider = oci.gru

    compartment_id = var.root_compartment
    display_name = "drg-interno"   
}

resource "oci_core_drg" "vcp_drg-interno" { 
    provider = oci.vcp

    compartment_id = var.root_compartment
    display_name = "drg-interno"   
}