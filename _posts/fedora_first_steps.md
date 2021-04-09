---
layout: post
title: Fedora, новый опыт в Linux
date: 2021-04-10 00:33:45 +0700
tags: linux Fedora nginx php
---

# Первое знакомство

Опыт установки Fedora привнёс много нового опыта, после опыта использования FreeBSD, Ubuntu, Gentoo, Archlinux.

В первую очередь, конечно, это система управления пакетами dnf, бывший yum, с которым я знакомился при установке CentOS, а точнее GosLinux. Но чтобы его использовать в реальных задачах, пришлось подключать репозитории CentOS, тогда.

Во-вторых, непривычно, что в операционной систем изначально включен файервол. Я привык не запускать ненужных сервисов, если они мне не нужны. А если они мне нужны, то я мог их запускать их на 127.0.0.1. Тут файервол изначально включен.

В-третьих, система изначально использует систему безопасности SELinux. Как говорят источники в интернете, эта система была разработана американской службой безопасности АНБ. Проверять я это не буду, но данная система доступа к ядре Linux и её можно использовать. В Fedora она включена в довольно лёгком режиме. Всё, что не описано правилами безопасности можно, всё что описано можно или нельзя, в зависимости от правил. Как я выяснил на практике, большинство того, что вам необходимо, работает. При этом работа стандартных служб довольно ограничена и если они потребуют доступ туда, куда обычно не требуется, то им будет отказано. У меня при использовании на ноутбуке в качестве рабочего копмьютера и на Raspberry Pi в качестве веб-сервера с php и postgresql особых проблем не возникло.

В первую очередь нужно проверить список используемых репозиториев:
```
dnf repolist
```
Если вы не с США и хотите соблюдать лицензионные ограничения, то можно отключить
```
sudo dnf config-manager --set-disabled fedora-cisco-openh264
```
Можно подключить полезные RPM-Fusion, со свободным софтом и не свободным:
```
sudo dnf install --nogpgcheck https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Если не новичок и вдруг обнаружили у себя что-то testing, то можно отключить лишнее, которые вам точно не нужны и вы на них не подписывались:
```
dnf config-manager --set-disabled updates-testing
dnf config-manager --set-disabled updates-testing-modular
```
# Ненужные порты

У меня изначально на Fedora был открыт порт 5355. который числится как LLMNR. Можете погуглить что это такое, и если вам оно не нужно, то можно просто отключить эту фигню через файл /etc/systemd/resolved.conf установив LLMNR=no.

# Настройка NGINX

В первую очередь вам нужно разрешить доступ к серверу.
```
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
```
... Много деталей

# Настройка php

Устанавливаемым php для командной строки и php-fpm. если нужно. Попутно нужные модули:
```
dnf install php-cli php-fpm php-pgsql php-json php-mbstring
```
Мне ещё понадобился php-process для работы с разделяемой памятью, семафорами и очередями.

При настройке fpm не забыть
```
;listen.acl_users = apache,nginx
```
Если нужны подключения по сети с сервера (в том числе proxy). то включить:
```
setsebool -P httpd_can_network_connect 1
```
Разрешить читать веб-серверу файлы
```
semanage fcontext -a -t httpd_sys_content_t "/home/fsa/www(/.*)?"
```
Разрешить писать веб-серверу файлы
```
semanage fcontext -a -t httpd_sys_rw_content_t "/home/fsa/www/log(/.*)?"
```
После изменений нужно запустить обновление ACL в соответствии с новыми правилами:
```
restorecon -R -v /home/fsa/www
```
Просмотреть ваши правила:
```
semanage fcontext -C -l
```

# SELinux
```
cat /var/log/audit/audit.log | audit2allow -m myapp > myapp.te
```
редактируем и компилируем
```
checkmodule -M -m -o myapp.mod myapp.te
semodule_package -o myapp.pp -m myapp.mod
semodule -i myapp.pp
```
Удаление модуля
```
semodule -r myapp
```
# Установка PostgreSQL
```
dnf install postgresql-server
```
Инициализация базы данных:
```
postgresql-setup initdb
```

```
su postges
psql
create user fsa superuser createrole createdb;
create database fsa owner fsa;
\password fsa
```

/var/lib/pgsql/data/pg_hba.conf установить md5
