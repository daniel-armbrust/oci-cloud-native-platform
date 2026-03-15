#
# vcn-oke/drg.tf
#

# DRG - Import Route Distribution
resource "oci_core_drg_route_distribution" "drg-interno_vcn-oke_imp-rt-dst" {
    drg_id = var.drg_id
    distribution_type = "IMPORT"
    display_name = "import-routes_vcn-oke"
}

# DRG Route Table
resource "oci_core_drg_route_table" "drg-interno-rt_vcn-oke" {  
    drg_id = var.drg_id
    display_name = "drg-rt_vcn-oke"
   
    import_drg_route_distribution_id = oci_core_drg_route_distribution.drg-interno_vcn-oke_imp-rt-dst.id
}

resource "oci_core_drg_route_table_route_rule" "drg-interno_vcn-oke_rt-routerule-1" {
    drg_route_table_id = oci_core_drg_route_table.drg-interno-rt_vcn-oke.id

    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"

    next_hop_drg_attachment_id = var.drg-interno-attch_vcn-fw-int_id
}

resource "oci_core_drg_route_table_route_rule" "drg-interno_vcn-oke_rt-routerule-2" {
    drg_route_table_id = oci_core_drg_route_table.drg-interno-rt_vcn-oke.id

    destination = "::/0"
    destination_type = "CIDR_BLOCK"

    next_hop_drg_attachment_id = var.drg-interno-attch_vcn-fw-int_id
}

# DRG Attachment
resource "oci_core_drg_attachment" "drg-interno-attch_vcn-oke" {
    drg_id = var.drg_id
    display_name = "drg-attch_vcn-oke"

    network_details {
        id = oci_core_vcn.vcn-oke.id
        type = "VCN"
        vcn_route_type = "VCN_CIDRS"               
    }

    drg_route_table_id = oci_core_drg_route_table.drg-interno-rt_vcn-oke.id
}