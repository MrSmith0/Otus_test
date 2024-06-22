#!/bin/bash

# Обновляем пакеты и устанавливаем Rsyslog
sudo apt update -y
sudo apt install rsyslog logrotate -y

# Включаем модули UDP и TCP для Rsyslog
sudo sed -i '/^#module(load="imudp")/s/^#//' /etc/rsyslog.conf
sudo sed -i '/^#input(type="imudp" port="514")/s/^#//' /etc/rsyslog.conf
sudo sed -i '/^#module(load="imtcp")/s/^#//' /etc/rsyslog.conf
sudo sed -i '/^#input(type="imtcp" port="514")/s/^#//' /etc/rsyslog.conf

sudo bash -c 'cat <<EOF > /etc/rsyslog.d/60-separate-logs.conf
\$template RemoteLogs,"/var/log/%FROMHOST-IP%/%PROGRAMNAME%.log"
*.* ?RemoteLogs
& ~
EOF'

sudo bash -c 'cat <<EOF > /etc/logrotate.d/rsyslog
/var/log/*/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 syslog adm
    sharedscripts
    postrotate
        /usr/lib/rsyslog/rsyslog-rotate
        systemctl reload rsyslog > /dev/null
    endscript
}
EOF'

sudo rm -rf /var/log/*
# Перезапускаем Rsyslog для применения настроек
sudo systemctl restart rsyslog
sudo systemctl restart logrotate

# Обновление системы
sudo apt update
sudo apt upgrade -y

# Установка MySQL
sudo apt install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql

# Настройка MySQL
sudo mysql -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'P3run6k8';"
sudo mysql -e "GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';"
sudo mysql -e "set global log_bin_trust_function_creators = 1;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Установка репозитория Zabbix
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb  
dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb  
sudo apt update

# Установка Zabbix сервера, веб-интерфейса и агента
sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent -y

# Импорт начальной схемы и данных в базу данных
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -pP3run6k8 zabbix

# Настройка Zabbix сервера
sudo sed -i 's/# DBPassword=/DBPassword=P3run6k8/' /etc/zabbix/zabbix_server.conf

# Запуск и включение Zabbix сервера и агента
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2
