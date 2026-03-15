#!/bin/bash

# Ajuste do TimeZone para "America/Sao_Paulo"
#/usr/bin/timedatectl set-timezone America/Sao_Paulo

# Atualiza, Instala e remove pacotes do Sistema Operacional
#/usr/bin/dnf -y update
/usr/bin/nice -n 15 /usr/bin/dnf -y install traceroute net-tools python39-oci-cli iptraf-ng
/usr/bin/nice -n 15 /usr/bin/dnf -y remove setroubleshoot-server

# Desabilita o SELinux
setenforce 0
/usr/bin/sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Desabilita o Firewall do Sistema Operacional
systemctl disable --now firewalld

# Habilita o daemon OCID
# https://docs.oracle.com/en-us/iaas/oracle-linux/oci-utils/index.htm#oci-network-config__config_vnic
/usr/bin/systemctl enable --now ocid.service

# Aumenta o tamanho do boot volume
/usr/libexec/oci-growfs -y

# Cria o arquivo rc.local
cat <<EOF >/etc/rc.d/rc.local
#!/bin/bash

# Download do script de configuração do Firewall e Policy Routing.
oci --auth instance_principal os object get --bucket-name scripts-storage --name rc-firewal.sh --file /etc/rc-firewall.sh

# Execução do script de configuração do Firewall e Policy Routing.
chmod 0500 /etc/rc-firewall.sh
#/etc/rc-firewall.sh

# From /etc/rc.local
touch /var/lock/subsys/local
EOF

# Start and enable the rc-local service
chmod +x /etc/rc.d/rc.local
systemctl start rc-local
systemctl enable rc-local

exit 0