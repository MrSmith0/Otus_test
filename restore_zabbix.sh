#!/bin/bash

# Настройки
BACKUP_DIR="/root/backup" #zabbix_bak
MYSQL_USER="zabbix"
MYSQL_PASSWORD="P3run6k8"
DATABASE="zabbix"
TIMESTAMP="2024-06-24"  # Дата бэкапа, который нужно восстановить

BACKUP_FILE="$BACKUP_DIR/zabbix_db_backup_$TIMESTAMP.sql"
CONFIG_BACKUP_DIR="$BACKUP_DIR/config_backup_$TIMESTAMP"


#Загрузка и распаковка tar архива в директорию /var/www/html
TAR_FILE_URL="https://github.com/MrSmith0/Otus_test/raw/main/dotfiles/backup-zabbix.tar"
TAR_FILE="backup-zabbix.tar" 

sudo wget $TAR_FILE_URL
sudo tar -xvf $TAR_FILE -C "/root/"

# Остановка Zabbix сервера и агента
sudo systemctl stop zabbix-server zabbix-agent apache2

# Восстановление базы данных
sudo mysql -e "DROP DATABASE $DATABASE;"
sudo mysql -e "CREATE DATABASE $DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;"
sudo mysql $DATABASE < $BACKUP_FILE
sudo mysql -e "GRANT ALL PRIVILEGES ON $DATABASE.* TO '$MYSQL_USER'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "set global log_bin_trust_function_creators = 1;"
sudo mysql -e "FLUSH PRIVILEGES;"
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось восстановить базу данных"
    exit 1
fi

# Восстановление конфигурационных файлов
sudo cp -r $CONFIG_BACKUP_DIR/zabbix/etc/
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось восстановить конфигурационные файлы Zabbix"
    exit 1
fi

# Восстановление конфигурации веб-сервера Apache
sudo cp $CONFIG_BACKUP_DIR/zabbix.conf/etc/apache2/conf-enabled/
if [ $? -ne 0 ]; then
    echo "Ошибка: не удалось восстановить конфигурационный файл Apache"
    exit 1
fi


# Запуск Zabbix сервера и агента
sudo systemctl start zabbix-server zabbix-agent apache2

echo "Восстановление Zabbix из бэкапа успешно завершено"
