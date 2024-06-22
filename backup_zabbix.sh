#!/bin/bash

# Настройки
BACKUP_DIR="/path/to/backup/dir"
MYSQL_USER="zabbix"
MYSQL_PASSWORD="your_password"
DATABASE="zabbix"
TIMESTAMP=$(date +"%F")
BACKUP_FILE="$BACKUP_DIR/zabbix_db_backup_$TIMESTAMP.sql"
CONFIG_BACKUP_DIR="$BACKUP_DIR/config_backup_$TIMESTAMP"

# Создание директории для бэкапа
mkdir -p $BACKUP_DIR
mkdir -p $CONFIG_BACKUP_DIR

# Бэкап базы данных
mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $DATABASE > $BACKUP_FILE
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось создать бэкап базы данных"
    exit 1
fi

# Копирование конфигурационных файлов
cp -r /etc/zabbix $CONFIG_BACKUP_DIR/
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось скопировать конфигурационные файлы"
    exit 1
fi

# Копирование конфигурации веб-сервера Apache
cp /etc/apache2/conf-enabled/zabbix.conf $CONFIG_BACKUP_DIR/
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось скопировать конфигурационный файл Apache"
    exit 1
fi


echo "Бэкап Zabbix успешно создан в $BACKUP_DIR"
