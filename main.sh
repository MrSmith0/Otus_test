#!/bin/bash

# Устанавливаем sshpass, если он не установлен
if ! command -v sshpass &> /dev/null; then
    sudo apt-get update -y
    sudo apt-get install sshpass -y
fi

# Указываем данные для подключения по SSH
MASTER_HOST="192.168.1.102"
SLAVE_HOST="192.168.1.103"
WORDPRESS_HOST="192.168.1.101"
NGINX_HOST="192.168.1.100"
ZABBIX_HOST="192.168.1.104"
SSH_USER="root"
SSH_PASSWORD="!P3run6k8"

# Функция для выполнения скрипта на удалённом сервере
execute_remote_script() {
    local host=$1
    local script_path=$2
    sshpass -p "${SSH_PASSWORD}" ssh -o StrictHostKeyChecking=no "${SSH_USER}@${host}" "bash -s" < "${script_path}"
}

echo "Выберите, какой скрипт вы хотите запустить:"
echo "1. Настройка MySQL Master"
echo "2. Настройка MySQL Slave"
echo "3. Настройка сервера WordPress"
echo "4. Настройка Nginx как балансировщика нагрузки"
echo "5. Настройка Zabbix + Rsyslog + Logrotate"
echo "6. Запустить все скрипты"
echo "7. Восстановление MySQL Master"
echo "8. Выход"

read -p "Введите номер опции: " choice

case $choice in
    1)
        echo "Запуск настройки MySQL Master..."
        execute_remote_script "${MASTER_HOST}" "scripts/master-mysql-setup.sh"
        ;;
    2)
        echo "Запуск настройки MySQL Slave..."
        execute_remote_script "${SLAVE_HOST}" "scripts/slave-mysql-setup.sh"
        ;;
    3)
        echo "Запуск настройки сервера WordPress..."
        execute_remote_script "${WORDPRESS_HOST}" "scripts/wordpress-setup.sh"
        ;;
    4)
        echo "Запуск настройки Nginx как балансировщика нагрузки..."
        execute_remote_script "${NGINX_HOST}" "scripts/load-balancer-setup.sh"
        ;;
    5)
        echo "Запуск настройки Zabbix и rsyslog..."
        execute_remote_script "${ZABBIX_HOST}" "scripts/zabbix_rsyslog.sh"
        ;;
    6)
        echo "Запуск всех скриптов..."
        execute_remote_script "${MASTER_HOST}" "scripts/master-mysql-setup.sh"
        execute_remote_script "${SLAVE_HOST}" "scripts/slave-mysql-setup.sh"
        execute_remote_script "${WORDPRESS_HOST}" "scripts/wordpress-setup.sh"
        execute_remote_script "${NGINX_HOST}" "scripts/load-balancer-setup.sh"
        execute_remote_script "${ZABBIX_HOST}" "scripts/zabbix_rsyslog.sh"
        ;;
    7)
        echo "Запуск восстановления MySQL Master..."
        execute_remote_script "${MASTER_HOST}" "scripts/mysql_mater_restore.sh"
        ;;
    8)
        echo "Выход."
        exit 0
        ;;
    *)
        echo "Неверный ввод, попробуйте еще раз."
        ;;
esac
