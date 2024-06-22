#!/bin/bash

# Обновляем пакеты и устанавливаем MySQL Server
sudo apt update && sudo apt upgrade -y
sudo apt install mysql-server -y
rm /etc/mysql/mysql.conf.d/mysqld.cnf

sudo bash -c 'cat > /etc/mysql/mysql.conf.d/mysqld.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
server-id = 1
log-bin = mysql-bin
binlog_format = row
gtid-mode=ON
enforce-gtid-consistency
log-replica-updates
EOF'

# Настраиваем MySQL 
sudo mysql -e "CREATE USER replica@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'P3run6k8';"
sudo mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo systemctl restart mysql
sudo mysql -e "CREATE USER root@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'P3run6k8';"
sudo mysql -e "GRANT ALL PRIVILEGES ON * . * TO 'root'@'%';"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo systemctl restart mysql


# Обновляем пакеты и устанавливаем Rsyslog
sudo apt update -y
sudo apt install rsyslog -y

# Добавляем конфигурацию для отправки логов на центральный сервер (замените central_rsyslog_server_ip на IP вашего сервера с Rsyslog)
sudo bash -c 'cat <<EOF > /etc/rsyslog.d/50-default.conf
*.* @31.128.41.137:514
EOF'

# Перезапускаем Rsyslog для применения настроек
sudo systemctl restart rsyslog

# Переменные для конфигурации
ZABBIX_SERVER="31.128.41.137"
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
