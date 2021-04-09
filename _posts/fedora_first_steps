---
layout: post
title: Fedora, новый опыт в Linux
date: 2021-04-10 00:33:45 +0700
tags: linux Fedora nginx php
---

# Первое знакомство

```
dnf repolist
sudo dnf install --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --set-disabled fedora-cisco-openh264
```

Отключение тестовых репозиториев
```
dnf config-manager --set-disabled updates-testing
dnf config-manager --set-disabled updates-testing-modular
```
# Ненужные порты

Порт 5355 LLMNR
Отключить /etc/systemd/resolved.conf LLMNR=no

# Настройка NGINX

firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Настройка php

dnf list installed

dnf install php-cli php-fpm php-pgsql php-pgsql php-process php-json php-mbstring
php-process - семафоры, разделяемая память
php-pgsql тянет за собой php-pdo

php-gd - графика
php-xml

php-domxml-php4-php5 -нужен или нет?

Не забыть
;listen.acl_users = apache,nginx

Для proxy_pass в nginx
setsebool -P httpd_can_network_connect 1
Система ругалась, что php-fpm не может читать index.php и  предложила сделать:
setsebool -P httpd_read_user_content 1
setsebool -P httpd_can_network_connect_db 1 или (пришлось)
setsebool -P httpd_can_network_connect 1

semanage fcontext -a -t httpd_sys_content_t "/home/fsa/NetBeansProjects(/.*)?"
semanage fcontext -a -t httpd_sys_rw_content_t "/home/fsa/NetBeansProjects/shcc/config(/.*)?"
semanage fcontext -a -t httpd_sys_rw_content_t "/home/fsa/NetBeansProjects/shcc/logs(/.*)?"
restorecon -R -v /home/fsa/NetBeansProjects либо перезагрузка
Просмотр чего натворили
semanage fcontext -C -l
https://losst.ru/nastrojka-selinux

https://fedoraproject.org/wiki/SELinux/apache

Изменение контекста для папки веб
chcon -Rv --type=httpd_sys_content_t /home/losst/htdocs
Даёт временный эффект.

grep php-fpm /var/log/audit/audit.log | grep shm | audit2allow -M php-fpm-shm

semodule -i mysql_tmpfs.pp

Создание своего модуля SELinux
cat /var/log/audit/audit.log | audit2allow -m myapp > myapp.te
редактируем и компилируем
checkmodule -M -m -o myapp.mod myapp.te
semodule_package -o myapp.pp -m myapp.mod
semodule -i myapp.pp

Удаление модуля
semodule -r myapp


#!/bin/bash

cd
semodule -r myapp
rm -f myapp.mod myapp.pp
checkmodule -M -m -o myapp.mod myapp.te
semodule_package -o myapp.pp -m myapp.mod
semodule -i myapp.pp


dnf install postgresql-server
postgresql-contrib - надо ли?
тянет за собой postgresql - клиента
postgresql-setup initdb

su postges
create user fsa superuser createrole createdb;
create database fsa owner fsa;
\password fsa

/var/lib/pgsql/data/pg_hba.conf установить md5


