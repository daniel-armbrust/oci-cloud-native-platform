#
# drg-externo.tf
#

resource "oci_core_drg" "gru_drg-externo" { 
    provider = oci.gru

    compartment_id = var.root_compartment
    display_name = "drg-externo"   
}

resource "oci_core_drg" "vcp_drg-externo" { 
    provider = oci.vcp

    compartment_id = var.root_compartment
    display_name = "drg-externo"   
}