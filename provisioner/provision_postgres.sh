#!/usr/bin/env bash

# Verificar a distribuição Linux
distro=""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    distro=$ID
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    distro=$DISTRIB_ID
elif [ -f /etc/debian_version ]; then
    distro="debian"
elif [ -f /etc/fedora-release ]; then
    distro="fedora"
elif [ -f /etc/redhat-release ]; then
    if grep -q "CentOS" /etc/redhat-release; then
        if grep -q "7\." /etc/redhat-release; then
            distro="centos7"
        else
            distro="centos"
        fi
    else
        distro="redhat"
    fi
else
    echo "Não foi possível detectar a distribuição Linux."
    exit 1
fi

echo "Distribuição Linux detectada: $distro"

# Instalar o PostgreSQL com base na distribuição
case $distro in
    "ubuntu" | "debian")
        echo "Instalando o PostgreSQL no Ubuntu/Debian..."
        sudo apt update > /dev/null 2>&1
        sudo apt install -y postgresql > /dev/null 2>&1
        ;;
    "fedora" | "centos")
        echo "Instalando o PostgreSQL no Fedora/CentOS..."
        if [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y postgresql-server > /dev/null 2>&1
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y postgresql-server > /dev/null 2>&1
        else
            echo "Gerenciador de pacotes não encontrado: dnf ou yum."
            exit 1
        fi
        ;;
    "centos7")
        echo "Instalando o PostgreSQL no CentOS 7..."
        sudo yum install -y postgresql-server > /dev/null 2>&1
        ;;
    *)
        echo "Distribuição Linux não suportada."
        exit 1
        ;;
esac

# Configurar a conexão para todos os hosts
echo "Configurando a conexão para todos os hosts..."
sleep 3

# Arquivo de configuração do PostgreSQL
pg_config=""

case $distro in
    "ubuntu" | "debian" | "centos7")
        pg_config="/etc/postgresql/*/main/postgresql.conf"
        ;;
    "fedora" | "centos")
        pg_config="/var/lib/pgsql/data/postgresql.conf"
        ;;
    *)
        echo "Distribuição Linux não suportada."
        exit 1
        ;;
esac

# Verificar se o diretório de dados existe e está vazio
data_dir="/var/lib/pgsql/data"
if [ -d "$data_dir" ] && [ -z "$(ls -A "$data_dir")" ]; then
    echo "O diretório de dados está vazio. Inicializando o cluster..."
    if [ "$distro" == "centos7" ] || [ "$distro" == "centos" ]; then
        sudo postgresql-setup initdb > /dev/null 2>&1
    else
        sudo pg_ctl initdb -D "$data_dir" > /dev/null 2>&1
    fi
fi

# Configuração específica para cada distribuição
case $distro in
    "ubuntu" | "debian" | "centos7")
        # Configuração para permitir conexões de todos os hosts, se ainda não estiver configurado
        #if ! grep -q "^listen_addresses" "$pg_config"; then
            echo "Alterando o arquivo: postgresql.conf"
            sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '0.0.0.0'/g" "$pg_config"
        #fi
        ;;
    "fedora" | "centos")
        # Configuração para permitir conexões de todos os hosts, se ainda não estiver configurado
        #if ! grep -q "^listen_addresses" "$pg_config"; then            
            echo "Alterando o arquivo: postgresql.conf"
            sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '0.0.0.0'/g" "$pg_config"
        #fi

        # Configuração adicional para permitir conexões remotas no CentOS, se ainda não estiver configurado
        pg_hba_config="/var/lib/pgsql/data/pg_hba.conf"        
        #if ! grep -q "^host" "$pg_hba_config"; then
            echo "Alterando o arquivo: pg_hba.conf"
            sudo sed -i 's/127\.0\.0\.1\/32\|localhost/0.0.0.0\/0/g; s/md5\|ident/trust/g' "$pg_hba_config"
        #fi
        ;;
    *)
        echo "Distribuição Linux não suportada."
        exit 1
        ;;
esac

# Reiniciar o serviço PostgreSQL se não estiver em execução
echo "Reiniciando o serviço PostgreSQL..."
if ! systemctl is-active --quiet postgresql; then
    if [ "$distro" == "centos7" ] || [ "$distro" == "centos" ]; then
        echo "Reiniciando o serviço PostgreSQL no CentOS 7..."
        sudo service postgresql restart || sudo systemctl restart postgresql
    else
        echo "Reiniciando o serviço PostgreSQL..."
        sudo systemctl restart postgresql || sudo service postgresql restart
    fi
fi

DATABASE=postgres
username='sog'
IP=$(hostname -I | awk '{print $2}')

# Criar um usuário com permissão full
sudo -u postgres createuser -s "$username"

# Gerar uma senha aleatória para o usuário
password=$(date +%s | sha256sum | base64 | head -c 16)
echo "Senha gerada para o usuário '$username': $password"

# Exibir o usuário e a senha
echo "Usuário: $username"
echo "Senha: $password"
echo "IP VM: $IP"

#Salva a senha do DB na home do user vagrant
echo "$password" >> /home/vagrant/postgres_pass.txt

echo -e "Para conectar-se ao DB basta seguir os passos:\n"
echo -e "01 - possuir um SGBD, por exemplo, HEID ou DBEAVER\n"
echo -e "02 - Criar uma nova conexão para o PostgreSQL\n"
echo -e "03 - Utilizar o database: $DATABASE junto com as credenciais fornecidas acima\n"
echo -e "04 - O host a ser utilizado pode ser o localhost ou $IP"


