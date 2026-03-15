#
# vcn-fw-ext/gateway.tf
#

# Service Gateway
resource "oci_core_service_gateway" "sgw" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-fw-ext.id
    display_name = "sgw"

    services {     
        service_id = var.sgw_all_oci_services
    }
}