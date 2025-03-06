!/bin/bash

# ============================
# 🚀 SCRIPT DE INSTALAÇÃO 🚀
# ============================

# Atualiza os pacotes do sistema
echo "🔄 Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# Instala pacotes necessários
echo "📦 Instalando pacotes essenciais..."
sudo apt install -y curl ca-certificates gnupg lsb-release unzip

# Adiciona repositório oficial do Docker
echo "🐳 Adicionando repositório do Docker..."
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza lista de pacotes novamente
echo "🔄 Atualizando pacotes após adicionar repositório do Docker..."
sudo apt update

# Instala Docker e Docker Compose
echo "📦 Instalando Docker e Docker Compose..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Adiciona usuário ao grupo Docker (evita usar sudo em comandos Docker)
echo "👤 Adicionando usuário ao grupo Docker..."
sudo usermod -aG docker $USER
newgrp docker

# Verifica se Docker foi instalado corretamente
echo "🐳 Verificando instalação do Docker..."
docker --version
docker compose version

# Criando diretórios necessários
echo "📂 Criando diretórios para volumes Docker..."
mkdir -p /docker/{glpi,glpi/percona,glpi/backup,zabbix-db,zabbix_server_data,nginx-db,nginx_data,nginx_letsencrypt,grafana_data}

# Ajustando permissões dos diretórios
echo "🔧 Ajustando permissões dos diretórios..."
sudo chown -R 1000:1000 /docker
sudo chmod -R 777 /docker

# Baixando arquivos docker-compose.yml e .env
echo "📥 Baixando arquivos necessários..."
curl -o /docker/docker-compose.yml https://github.com/Andrefiel/scriptmonitoramento/blob/main/docker-compose2.yml
curl -o /docker/.env https://github.com/Andrefiel/scriptmonitoramento/blob/main/.env

# Iniciando os containers
echo "🚀 Iniciando os containers Docker..."
cd /docker
docker compose up -d
