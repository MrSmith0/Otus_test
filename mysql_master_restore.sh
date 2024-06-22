#!/bin/bash

# Загрузка и выполнение SQL файла в базу данных WordPress
SQL_FILE_URL="http://31.128.40.200/files/wp.sql"
SQL_FILE="/tmp/wp.sql"

sudo wget $SQL_FILE_URL -O $SQL_FILE
sed 's/USE `database_name`;/USE `new_database_name`;/' -i $SQL_FILE
sudo mysql -e "RESET MASTER;"
sudo mysql wp -uroot -pP3run6k8 < $SQL_FILE
rm $SQL_FILE
