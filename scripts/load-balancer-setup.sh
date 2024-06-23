#!/bin/bash

# Обновляем пакеты и устанавливаем Nginx
sudo apt update -y
sudo apt install nginx -y

# Конфигурируем Nginx для балансировки нагрузки
sudo bash -c 'cat <<EOF > /etc/nginx/sites-available/load_balancer
upstream wordpress_servers {
    server 192.168.1.101:8080;
    server 192.168.1.101:8081;
}

server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://wordpress_servers;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF'

# Активируем конфигурацию Nginx для балансировки нагрузки
sudo ln -s /etc/nginx/sites-available/load_balancer /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

# Перезапускаем Nginx для применения настроек
sudo systemctl restart nginx


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
wget https://github.com/MrSmith0/Otus_test/raw/main/dotfiles/libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb
dpkg -i libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb

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
