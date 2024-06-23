#!/bin/bash

# Установка Apache2, PHP и необходимых пакетов
sudo apt update -y
sudo apt install apache2 php php-mysql libapache2-mod-php wget curl mysql-client -y

# Скачивание и установка WordPress
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvzf latest.tar.gz
sudo rm latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf wordpress

# Настройка прав доступа
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Настройка базы данных для WordPress
DB_NAME="wp"
DB_USER="wp"
DB_PASS="P3run6k8"
DB_HOST="192.168.1.102"

# Создание базы данных и пользователя MySQL
MYSQL_ROOT_PASSWORD="P3run6k8"  # Укажите здесь пароль пользователя root MySQL
MYSQL_COMMAND="mysql -h $DB_HOST -u root -p$MYSQL_ROOT_PASSWORD -e"

$MYSQL_COMMAND "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
$MYSQL_COMMAND "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
$MYSQL_COMMAND "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
$MYSQL_COMMAND "FLUSH PRIVILEGES;"


 Загрузка и распаковка tar архива в директорию /var/www/html
TAR_FILE_URL="https://github.com/MrSmith0/Otus_test/raw/main/dotfiles/html.tar"
TAR_FILE="/tmp/html.tar"

sudo rm -rf /var/www/* 
sudo wget $TAR_FILE_URL -O $TAR_FILE
sudo tar -xvf $TAR_FILE -C /var/www/

# Настройка виртуального хоста Apache
sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:8081>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/001-default.conf
<VirtualHost *:8080>
    ServerAdmin admin@example.com
    DocumentRoot /var/www/html
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

sudo rm /etc/apache2/ports.conf 
sudo bash -c 'cat <<EOF > /etc/apache2/ports.conf
Listen 8080
Listen 8081

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
EOF'

# Включение конфигурации и перезапуск Apache
sudo a2ensite 000-default.conf
sudo a2ensite 001-default.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Очистка временных файлов, если это необходимо
sudo rm $SQL_DUMP_FILE
sudo rm $TAR_FILE


# Обновляем пакеты и устанавливаем Rsyslog
sudo apt update -y
sudo apt install rsyslog -y

# Добавляем конфигурацию для отправки логов на центральный сервер (замените central_rsyslog_server_ip на IP вашего сервера с Rsyslog)
sudo bash -c 'cat <<EOF > /etc/rsyslog.d/50-default.conf
*.* @192.168.1.104:514
EOF'

# Перезапускаем Rsyslog для применения настроек
sudo systemctl restart rsyslog

# Переменные для конфигурации
ZABBIX_SERVER="192.168.1.104"
ZABBIX_AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"

# Установка необходимых зависимостей
sudo apt update -y
sudo apt install -y wget gnupg libldap-common libssl-dev
curl -O http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb

# Добавление репозитория Zabbix
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix/zabbix-agent2_7.0.0-1%2Bubuntu24.04_amd64.deb
sudo dpkg -i zabbix-agent2_7.0.0-1+ubuntu24.04_amd64.deb
sudo apt update -y

# Установка Zabbix агента
sudo apt install -y zabbix-agent2

# Настройка конфигурационного файла Zabbix агента
sudo sed -i "s/^Server=127.0.0.1/Server=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF
sudo sed -i "s/^ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF
sudo sed -i "s/^Hostname=Zabbix server/Hostname=$(hostname)/" $ZABBIX_AGENT_CONF

# Перезапуск и включение Zabbix агента
sudo systemctl daemon-reload
sudo systemctl restart zabbix-agent2
sudo systemctl enable zabbix-agent2
