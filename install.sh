#!/bin/bash

# Atualização e limpeza do sistema
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Configuração de rede
sudo hostnamectl set-hostname SRV-MONITORAMENTO
echo "192.168.1.110 SRV-MONITORAMENTO" | sudo tee -a /etc/hosts

# Instalação do Nginx e Certbot
sudo apt install -y nginx certbot python3-certbot-nginx

##cockpit
apt install cockpit -y
systemctl start cockpit cockpit.socket && systemctl enable cockpit cockpit.socket

# Instalação do MySQL com senha
sudo apt install -y mysql-server
sudo mysql_secure_installation <<EOF

Y
Argos@DB
Argos@DB
Y
Y
Y
Y
EOF

systemctl enable mysql
systemctl start mysql

# Instalação do Zabbix completo (ajuste a versão conforme necessário)
apt-get install -y language-pack-en language-pack-pt
wget https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.2+ubuntu24.04_all.deb
apt update
apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

# mysql -uroot -pArgos@DB
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by 'Arg0s@zabbix';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> quit;

zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

# mysql -uroot -pArgos@DB
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;

#Editar arquivo /etc/zabbix/zabbix_server.conf
#DBPassword=Argos@DB

# Instalação do Grafana
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# Updates the list of available packages
sudo apt-get update
sudo apt-get install grafana -y
sudo systemctl start grafana-server && sudo systemctl enable grafana-server

# Instalação do NetBox (ajuste a versão conforme necessário)
sudo apt install -y python3-pip python3-dev libpq-dev git 
git clone -b master https://github.com/netbox-community/netbox.git /opt/netbox/
cd /opt/netbox/
pip3 install -r requirements.txt

# Instalação do Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Criação do usuário 'andre' e adição ao grupo sudoers
sudo adduser andre.fiel --gecos "" --disabled-password <<EOF
Argos@2025
Argos@2025
EOF

##SSMTP

apt-get install ssmtp snmp -y

# Adicionando o usuário 'andre' ao grupo sudo
sudo usermod -aG sudo andre.fiel

# Finalização com atualização e limpeza novamente
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

echo "Instalação concluída! O usuário 'andre' foi criado e adicionado ao grupo sudo."
