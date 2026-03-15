#!/bin/bash

# Configuração das interfaces de rede
/usr/bin/oci-network-config configure

# Tabela de Rotas da Rede Externa
if [ -z "`grep externo /etc/iproute2/rt_tables`" ]; then
   echo '500 externo' >> /etc/iproute2/rt_tables
fi

# VNIC - VCN-FIREWALL-EXT
vcn_fw_ext_cidr="`curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/metadata/vcn-fw-ext-cidr`"
firewall_ext_ip="`curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/metadata/firewall-ext-ip`"
firewall_ext_ip_gw="`curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/metadata/vcn-fw-ext-subnprv1-ip-gw`"
vnic_ext_iface="`ip -o -f inet addr show | grep "$firewall_ext_ip" | awk '{print $2}'`"

# VNIC - VCN-FIREWALL-INT
vcn_fw_int_cidr="`curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/metadata/vcn-fw-int-cidr`"
firewall_int_ip="`curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/metadata/firewall-int-ip`"
firewall_int_ip_gw="`curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/instance/metadata/vcn-fw-int-subnprv1-ip-gw`"
vnic_int_iface="`ip -o -f inet addr show | grep "$firewall_1_int_ip" | awk '{print $2}'`"

# Parâmetros do Kernel
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

echo 0 > /proc/sys/net/ipv4/conf/$vnic_ext_iface/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/$vnic_int_iface/rp_filter

echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 0 > /proc/sys/net/ipv4/conf/default/rp_filter

iptables -t filter -F
iptables -t filter -X
iptables -t filter -Z

iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -Z

iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z

# Evita que o range link-local seja roteado para a Internet
iptables -t mangle -A OUTPUT -o $vnic_int_iface -s $firewall_1_int_ip -d 169.254.0.0/16 -j RETURN

# NAT para a INTERNET
iptables -t nat -A POSTROUTING -o $vnic_int_iface -j MASQUERADE

exit 0