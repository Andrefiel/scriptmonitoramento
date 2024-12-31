#!/bin/bash

# Atualização e limpeza do sistema
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Configuração de rede
sudo hostnamectl set-hostname SRV-MONITORAMENTO
echo "192.168.1.110 SRV-MONITORAMENTO" | sudo tee -a /etc/hosts

# Configuração de IP fixo com Netplan
cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:  # Substitua 'ens33' pelo nome da sua interface de rede
      dhcp4: no
      addresses: [192.168.1.110/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [192.168.1.7, 192.168.1.2, 1.1.1.1]
EOF

# Aplicar configurações de rede
sudo netplan apply

# Instalação do Nginx e Certbot
sudo apt install -y nginx
sudo apt install -y certbot python3-certbot-nginx

# Instalação do MySQL com senha
sudo apt install -y mysql-server
sudo mysql_secure_installation <<EOF

Y
senha DB
senha DB
Y
Y
Y
Y
EOF

# Instalação do Zabbix completo (ajuste a versão conforme necessário)
wget https://cdn.zabbix.com/zabbix/binaries/stable/6.4/ubuntu/$(lsb_release -cs)/zabbix-release_6.4-1+$(lsb_release -cs)_all.deb
sudo dpkg -i zabbix-release_6.4-1+$(lsb_release -cs)_all.deb
sudo apt update
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-agent

# Instalação do Grafana
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:grafana/stable -y
sudo apt update
sudo apt install -y grafana

# Instalação do NetBox (ajuste a versão conforme necessário)
sudo apt install -y python3-pip python3-dev libpq-dev git 
git clone -b master https://github.com/netbox-community/netbox.git /opt/netbox/
cd /opt/netbox/
pip3 install -r requirements.txt

# Instalação do Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Criação do usuário 'andre' e adição ao grupo sudoers
sudo adduser andre --gecos "" --disabled-password <<EOF
Argos@2025
Argos@2025
EOF

# Adicionando o usuário 'andre' ao grupo sudo
sudo usermod -aG sudo andre

# Finalização com atualização e limpeza novamente
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

echo "Instalação concluída! O usuário 'andre' foi criado e adicionado ao grupo sudo."
