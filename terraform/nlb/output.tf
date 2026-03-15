#
# nlb/output.tf
#

#------------------------#
# NLB - Firewall Externo #
#------------------------#

output "nlb_fw-ext_private-ip_id" {
    value = data.oci_core_private_ips.nlb_fw-ext_private-ip.private_ips[0].id

    depends_on = [
        oci_network_load_balancer_listener.nlb_fw-ext_listener
    ]
}

#------------------------#
# NLB - Firewall Interno #
#------------------------#

output "nlb_fw-int_private-ip_id" {
    value = data.oci_core_private_ips.nlb_fw-int_private-ip.private_ips[0].id

    depends_on = [
        oci_network_load_balancer_listener.nlb_fw-int_listener
    ]
}

# output "nlb_fw-int_private-ipv6_id" {
#     value = data.oci_core_private_ips.nlb_fw-int_private-ipv6.private_ips[0].id

#     depends_on = [
#         oci_network_load_balancer_listener.nlb_fw-int_listener
#     ]
# }