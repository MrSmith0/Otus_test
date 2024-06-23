#!/bin/bash

# Обновляем пакеты и устанавливаем MySQL Server
sudo apt update && sudo apt upgrade -y
sudo apt install mysql-server -y

# Конфигурируем MySQL для репликации
rm /etc/mysql/mysql.conf.d/mysqld.cnf

sudo bash -c 'cat > /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
server-id = 2
log-bin = mysql-bin
relay-log = relay-log-server
read-only = ON
gtid-mode=ON
enforce-gtid-consistency
log-replica-updates
EOF'

# Перезапускаем MySQL
sudo systemctl restart mysql

# Настраиваем репликацию
MASTER_HOST='192.168.1.102'
REPLICA_USER='replica'
REPLICA_PASS='P3run6k8'

sudo mysql -e "CREATE USER root@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'P3run6k8';"
sudo mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'root'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"

sudo mysql -e "SHOW GLOBAL VARIABLES LIKE 'caching_sha2_password_public_key_path';"
sudo mysql -e "SHOW STATUS LIKE 'Caching_sha2_password_rsa_public_key'\G"

sudo mysql -e "STOP SLAVE;"
sudo mysql -e "CHANGE MASTER TO MASTER_HOST='${MASTER_HOST}', MASTER_USER='${REPLICA_USER}', MASTER_PASSWORD='${REPLICA_PASS}', MASTER_LOG_FILE='binlog.000003', MASTER_LOG_POS=1180, GET_MASTER_PUBLIC_KEY = 1;"
sudo mysql -e "START SLAVE;"

sudo mysql -e "STOP REPLICA;"
sudo mysql -e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='${MASTER_HOST}', SOURCE_USER='${REPLICA_USER}', SOURCE_PASSWORD='${REPLICA_PASS}', SOURCE_AUTO_POSITION = 1, GET_SOURCE_PUBLIC_KEY = 1;"
sudo mysql -e "START REPLICA;"
sudo systemctl restart mysql

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
