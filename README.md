1. На всех серверах запустить команду git clone https://github.com/MrSmith0/Otus_test.git
2. На сервере MonitoringLog запустить sh Otus_test/scripts/zabbix_rsyslog.sh
     затем на том же сервере запустить sh Otus_test/restore_zabbix.sh
       и перейти по адрес_сервера/zabbix логин - Admin пароль - zabbix
5. На сервере MySql-master запустить sh Otus_test/scripts/master-mysql-setup.sh
6. На сервере MySql-slave запустить sh Otus_test/scripts/slave-mysql-setup.sh
7.   проверить как работает репликация
         mysql
         show slave status\G
9. на сервер WordPress запустить sh Otus_test/scripts/wordpress-setup.sh
     после этого скрипта необходимо вернуться на сервер MySql-master и запустить:
       sh Otus_test/scripts/mysql_mater_restore.sh
10. дальше настраиваем сервер балансировки sh Otus_test/scripts/load-balancer-setup.sh

Мой проект состоит из 5 серверов 
------------------------------------
.    nginx(балансировщик)          .
------------------------------------

------------------------------------    
.  Apache на портах 8080           .
.                   8081           .
.   тут же крутится сам WordPress  .
------------------------------------

------------------------------------    
.    MySql-master                  .
------------------------------------

------------------------------------    
.    MySql-slave                   .
------------------------------------

------------------------------------
.   Мониторинг (zabbix)            .
.   Хранилище логов (Rsyslog)      .
.   и (logratate)                  .
------------------------------------
