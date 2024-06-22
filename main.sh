#!/bin/bash

echo "Выберите, какой скрипт вы хотите запустить:"
echo "1. Настройка MySQL Master"
echo "2. Настройка MySQL Slave"
echo "3. Настройка сервера WordPress"
echo "4. Настройка Nginx как балансировщика нагрузки"
echo "5. Настройка Zabbix + Rsyslog + Logrotate"
echo "6. Запустить все скрипты"
echo "7. Выход"

read -p "Введите номер опции: " choice

case $choice in
    1)
        echo "Запуск настройки MySQL Master..."
        bash scripts/master-mysql-setup.sh
        ;;
    2)
        echo "Запуск настройки MySQL Slave..."
        bash scripts/slave-mysql-setup.sh
        ;;
    3)
        echo "Запуск настройки сервера WordPress..."
        bash scripts/wordpress-setup.sh
        ;;
    4)
        echo "Запуск настройки Nginx как балансировщика нагрузки..."
        bash scripts/load-balancer-setup.sh
        ;;
    5)
        echo "Запуск настройки Zabbix и rsyslog..."
        bash scripts/zabbix_rsyslog.sh
        ;;
    6)
        echo "Запуск всех скриптов..."
        bash scripts/master-mysql-setup.sh
        bash scripts/slave-mysql-setup.sh
        bash scripts/wordpress-setup.sh
        bash scripts/load-balancer-setup.sh
        bash scripts/zabbix_rsyslog.sh
        ;;
    7)
        echo "Выход."
        exit 0
        ;;
    *)
        echo "Неверный ввод, попробуйте еще раз."
        ;;
esac
