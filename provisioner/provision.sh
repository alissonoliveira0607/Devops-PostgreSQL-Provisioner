
#!/bin/bash

# Verificar a distribuição Linux
if [ -f /etc/redhat-release ]; then
    DISTRO="centos"
elif [ -f /etc/lsb-release ]; then
    DISTRO="ubuntu"
else
    echo "Distribuição Linux não suportada."
    exit 1
fi

# Instalar o PostgreSQL
if [ "$DISTRO" = "centos" ]; then
    sudo yum -y install postgresql-server
elif [ "$DISTRO" = "ubuntu" ]; then
    sudo apt-get -y install postgresql
fi

#inicializando o cluster
sudo postgresql-setup initdb

# Iniciar o serviço do PostgreSQL
sudo systemctl start postgresql

# Verificar se o serviço está em execução
if ! sudo systemctl is-active --quiet postgresql; then
    echo "Falha ao iniciar o serviço do PostgreSQL."
    exit 1
fi



# Configurar a conexão para todos os hosts
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /var/lib/pgsql/data/postgresql.conf
sudo sed -i "s/host    all             all             127.0.0.1\/32            ident/host    all             all             0.0.0.0\/0               trust/" /var/lib/pgsql/data/pg_hba.conf

# Reiniciar o serviço do PostgreSQL
sudo systemctl restart postgresql

# Verificar se o serviço reiniciou com sucesso
if ! sudo systemctl is-active --quiet postgresql; then
    echo "Falha ao reiniciar o serviço do PostgreSQL."
    exit 1
fi

# Criar um usuário e senha
PASSWORD=$(openssl rand -base64 12)
sudo -u postgres psql -c "CREATE USER sog WITH PASSWORD '$PASSWORD' CREATEDB;"

# Imprimir informações de conexão
echo "Usuário: sog"
echo "Senha: $PASSWORD"
echo "IP VM: $(hostname -I | awk '{print $1}')"
