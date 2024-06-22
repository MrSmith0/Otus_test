#!/bin/bash

# Настройки
BACKUP_DIR="/root/backup/zabbix_bak" #zabbix_bak
MYSQL_USER="zabbix"
MYSQL_PASSWORD="P3run6k8"
DATABASE="zabbix"
TIMESTAMP="2024-06-22"  # Дата бэкапа, который нужно восстановить

BACKUP_FILE="$BACKUP_DIR/zabbix_db_backup_$TIMESTAMP.sql"
CONFIG_BACKUP_DIR="$BACKUP_DIR/config_backup_$TIMESTAMP"

#Загрузка и распаковка tar архива в директорию /var/www/html
TAR_FILE_URL="https://github.com/MrSmith0/Otus_test/blob/main/dotfiles/zabbix_bak.tar"
TAR_FILE= $BACKUP_DIR

sudo wget $TAR_FILE_URL -O $TAR_FILE
sudo tar -xvf $TAR_FILE -C $BACKUP_DIR

# Остановка Zabbix сервера и агента
sudo systemctl stop zabbix-server zabbix-agent apache2

# Восстановление базы данных
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "DROP DATABASE $DATABASE;"
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "CREATE DATABASE $DATABASE CHARACTER SET utf8 COLLATE utf8_bin;"
mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $DATABASE < $BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось восстановить базу данных"
    exit 1
fi

# Восстановление конфигурационных файлов
sudo cp -r $CONFIG_BACKUP_DIR/zabbix /etc/
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось восстановить конфигурационные файлы Zabbix"
    exit 1
fi

# Восстановление конфигурации веб-сервера Apache
sudo cp $CONFIG_BACKUP_DIR/zabbix.conf /etc/apache2/conf-enabled/
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось восстановить конфигурационный файл Apache"
    exit 1
fi


# Запуск Zabbix сервера и агента
sudo systemctl start zabbix-server zabbix-agent apache2

echo "Восстановление Zabbix из бэкапа успешно завершено"