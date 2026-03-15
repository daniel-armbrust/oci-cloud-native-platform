#
# vcn-oke/gateway.tf
#

# Internet Gateway
resource "oci_core_internet_gateway" "igw" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "igw"
    enabled = true
}

# Service Gateway
resource "oci_core_service_gateway" "sgw" {
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn-oke.id
    display_name = "sgw"

    services {     
        service_id = var.sgw_all_oci_services
    }
}