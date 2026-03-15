#
# vcn-fw-ext/drg.tf
#

# DRG - Import Route Distribution
resource "oci_core_drg_route_distribution" "drg-interno_vcn-fw-ext_imp-rt-dst" {
    drg_id = var.drg_id
    distribution_type = "IMPORT"
    display_name = "import-routes_vcn-fw-ext"
}

# DRG Attachment
resource "oci_core_drg_attachment" "drg-interno-attch_vcn-fw-ext" {
    drg_id = var.drg_id
    display_name = "drg-attch_vcn-fw-ext"

    network_details {
        id = oci_core_vcn.vcn-fw-ext.id
        type = "VCN"
        vcn_route_type = "VCN_CIDRS"               
    }

    # drg_route_table_id = oci_core_drg_route_table.drg-interno-rt_vcn-worker-nodes.id
}