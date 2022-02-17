---
layout: post
title: Умный дом на основе Majordomo
date: 2018-04-03 17:43:00 +0700
tags: [MajorDoMo, nginx]
excerpt: "Черновик: Установка контроллера сервера умного дома MajorDoMo"
---

Это черновая версия публикации. Возможно в ней содержатся неточности и отсутствуют некоторые поясняющие фрагменты. Даже не смотря на это текст можно использовать в качестве знакомства с принципами работы Majordomo. Публикация, скорее всего, не будет дорабатываться, т.к. после изучения исходных текстов данного продукта я отказался от его использования.

## Системные требования

Что нужно для работы majordomo:

* веб-сервер;
* php;
* mysql.

## Выбор веб-сервера

Так сложилось, что я не вижу большой необходимости в Apache для себя. Единственную функцию, которую он для меня выполняет - это разгребание .htaccess. Однако у меня нет задачи сделать хостинг для кого-то, у меня свой сервер, поэтому самым оптимальным будет спрятать эти правила в конфигурацию nginx. Тем более работающая конфигурация для nginx уже есть на сайте разработчиков.

Устанавливается nginx штатными средствами.

Файлы настроек nginx располагаются в папке /etc/nginx. В Debian-based дистрибутивах, в том числе Raspbian, nginx уже по умолчанию сконфигурирован на работу с виртуальными хостами, настройки которых хранятся в папке sites-available. Для включения виртуального хоста необходимо создать символическую ссылку в папке sites-enabled на созданный файл конфигурации виртуального хоста.

Если же конфигурация отличается, то можно самостоятельно прописать в секции http файла nginx.conf строку:

```nginx
include /etc/nginx/sites.d/*.conf;
```

В этом случае внутрь секции http будут включены все файлы с расширением .conf из папки sites.d, которую необходимо будет создать.

На этом предварительную настройку nginx можно считать законченной. Дальнейшую настройку можно будет провести после установки php.

## Установка PHP

Как известно на Apache можно установить PHP в виде модуля. Для nginx же из известных мне вариантов только подключение с использованием FastCGI. Впрочем, ещё в версии PHP 5.4 в самом PHP появился свой FastCGI Process Manager. Так что ничего лишнего устанавливать будет не нужно, всё уже есть &laquo;из коробки&raquo;.

На Raspbian установить почти всё необходимое можно с помощью команды:

```bash
sudo apt-get install php-fpm
```

Для работы php из командной строки необходимо установить модуль php-cli.

После установки необходимых модулей для запуска Majordomo у меня получился следующий список:

* php-cli;
* php-common;
* php-curl;
* php-fpm;
* php-gd;
* php-json;
* php-mbstring;
* php-mysql;
* php-opcache;
* php-readline;
* php-xml.

Стандартный скрипт установки Majordomo предлагает более широкий набор модулей:

```bash
sudo apt-get -qq install -y php
sudo apt-get -qq install -y php-bz2 
sudo apt-get -qq install -y php-cli 
sudo apt-get -qq install -y php-common 
sudo apt-get -qq install -y php-curl 
sudo apt-get -qq install -y php-gd 
sudo apt-get -qq install -y php-json 
sudo apt-get -qq install -y php-mbstring 
sudo apt-get -qq install -y php-mcrypt 
sudo apt-get -qq install -y php-mysql 
sudo apt-get -qq install -y php-opcache 
sudo apt-get -qq install -y php-readline
sudo apt-get -qq install -y php-xml 
sudo apt-get -qq install -y php-mysql 
sudo apt-get -qq install -y php-pear
sudo apt-get -qq install -y php-idn 
sudo apt-get -qq install -y php-imagick 
sudo apt-get -qq install -y php-imap 
sudo apt-get -qq install -y php-memcache 
sudo apt-get -qq install -y php-mhash 
sudo apt-get -qq install -y php-ming 
sudo apt-get -qq install -y php-ps 
sudo apt-get -qq install -y php-pspell 
sudo apt-get -qq install -y php-recode 
sudo apt-get -qq install -y php-snmp 
sudo apt-get -qq install -y php-tidy 
sudo apt-get -qq install -y php-xmlrpc 
sudo apt-get -qq install -y php-xsl 
sudo apt-get -qq install -y php-json
```

Если у вас возникли проблемы с функционированием Majordomo, можете доустановить рекомендуемое.

Возможно при установке модулей потребуется явно указать версию php, для чего в наименовании пакеты нужно прописать `php5-*` или `php7.0-*`. Лично я не рекомендую использовать PHP 5 версии, т.к. в версии 7.0 разработчиками проделана значительная работа по оптимизации производительности (для системы на Raspberry Pi это особенно важно из-за небольшого количества ресурсов) и, кроме того, PHP 7.0 вышла в конце 2015 года и по стабильности не хуже PHP 5.

Конфигурация php хранится, как правило, в папке `/etc/php`. При этом внутренняя структура может отличаться на разных дистрибутивах. Например, на Raspbian конфигурация FPM хранится в папке `/etc/php/7.0/fpm`, а в Gentoo `/etc/php/fpm-php7.0`. В любом случае структура похожа. Нас интересует папка `pool.d` или `fpm.d`, во втором случае. Внутри этой папки расположен файл `www.conf`. Это пул процессов по имени www обрабатывающий запросы к PHP.

Настроим пул. Необходимо сделать минимум изменений в оригинальном файле. Во-первых, нужно указать системное имя пользователя и группу от имени которого будет запущены процессы PHP. Самым оптимальным будет использование того же самого пользователя, что и указан в конфигурации веб-сервера. Находим следующие строки и указываем своего пользователя:

```nginx
user = www
group = www
```

Следующий интересующий нас параметр - прослушиваемый PHP-FPM сокет. Это может быть как TCP, так и unix. Можно просто записать значение параметра (его мы будем указывать в настройках nginx), либо указать своё значение. Вот так у меня выглядело значение по умолчанию:

```nginx
listen = 127.0.0.1:9000
```

Это самый простой способ настроить PHP-FPM. Однако, поскольку наш PHP-FPM работает на той же машине, что и веб-сервер, можно воспользоваться unix-сокетами. При этом серверу не нужно будет использовать весь стек протоколов TCP/IP, который имеет свои накладные расходы. Однако, при использовании unix-сокета необходимо, чтобы у создаваемого ресурса были корректно выставлены права доступа. Находим и настраиваем следующие параметры (некоторые нужно будет раскомментировать):

```nginx
listen = /run/php/php7.0-fpm.sock;
listen_owner = www
listen_group = www
listen_mode = 660
```

Вместо www укажите того же самого пользователя, что указывали в настройках веб-сервера и выше в этом файле конфигурации. Как не трудно догадаться, будет создан файл ресурса `/run/php/php7.0-fpm.sock` и владельцем www и группой www, а также правами доступа 660, т.е. доступный только для пользователя и группы, но не всех пользователей системы. Ещё неплохо будет убедиться, что папка `/run/php` существует и она доступна пользователю www (или того, который вы используете) для записи.

Теперь настал момент настройки nginx. Можно прописывать настройки php в каждый файл с виртуальным хостом, а можно прописать глобально. Даже не смотря на то, что у нас имеется только один виртуальный хост, воспользуемся вторым вариантом, как более &laquo;правильным&raquo;. Для этого в файле `/etc/nignx/nginx.conf` найдём секцию http и добавим следующие строки (можно это сделать в самом начале секции после открывающейся фигурной скобки):

```nginx
    upstream php-fpm {
 server unix:/run/php/php7.0-fpm.sock;
    }
```

Указанное нами имя php-fpm можно будет указывать в директиве `fastcgi_pass` в настройках виртуального хоста. Благодаря директиве upstream мы можем в любой момент изменить глобально настройки php, при этом все виртуальные хосты подхватят это изменение.

После этой настройки мой файл nginx.conf принял такой вид:

```nginx
user www;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
 worker_connections 768;
 # multi_accept on;
}

http {
    upstream php-fpm {
 server unix:/run/php/php7.0-fpm.sock;
    }

 ##
 # Basic Settings
 ##

 sendfile on;
 tcp_nopush on;
 tcp_nodelay on;
 keepalive_timeout 65;
 types_hash_max_size 2048;

 include /etc/nginx/mime.types;
 default_type application/octet-stream;

 ##
 # SSL Settings
 ##

 ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
 ssl_prefer_server_ciphers on;

 ##
 # Logging Settings
 ##

 access_log /var/log/nginx/access.log;
 error_log /var/log/nginx/error.log;

 ##
 # Gzip Settings
 ##

 gzip on;
 gzip_disable "msie6";

 # gzip_vary on;
 # gzip_proxied any;
 # gzip_comp_level 6;
 # gzip_buffers 16 8k;
 # gzip_http_version 1.1;
 # gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

 ##
 # Virtual Host Configs
 ##

 include /etc/nginx/conf.d/*.conf;
 include /etc/nginx/sites.d/*.conf;
}
```

## Настройка MySQL-сервера

В качестве MySQL-сервера для Majordomo можно использовать как оригинальный сервер, так и его форк - MariaDB. Детальную настройку сервера опишу чуть позже.

Тут необходимо описать как настроить сервер, как создать базу данных и залить туда информацию, а также указать куда прописать реквизиты доступа.

При использовании MariaDB по умолчанию для пользователя root подключен плагин unix_socket. Это означает, что пользователь root не может использоваться при TCP соединении. Из-за этого нельзя зайти через phpMyAdmin. Самым безопасным вариантом является создание через командную строку своего пользователя и назначить ему глобальные привилегии. В качестве альтернативы можно просто записать пустую строку в поле plugin базы user в базе данных mysql, что, конечно, понизит безопасность системы.

## Запуск сайта Majordomo

Основной интерфейс Majordomo выполнен в виде сайта. Скачиваем дистрибутив и распаковываем, например, в папку /var/www/majordomo. С помощью команды chown -R www:www /var/www/majordomo передаём эту папку нашему пользователю, от имени которого работает nginx и php. Задать права доступа для файлов и папок можно с помощью скрипта install-linux.sh в корневой папке. НО! В нём указаны команды chmod 777 и chmod 666, что явно излишне. Нам будет достаточно прав 770 и 660 или, даже, 750 и 640. Исправьте эти значения внутри файла, разрешите запуск скрипта с помощью команды chmod +x install-linux.sh и запустите его.

Создадим файл виртуального хоста в соответствующей папке, которую мы определили при настройке веб-сервера. Создаём там файл majordomo.conf:

```nginx
server {
    listen 80 default_server;
    server_name  majordomo.localhost;

    charset utf-8;

    access_log  /var/log/nginx/majordomo_access.log;
    error_log  /var/log/nginx/majordomo_error.log;

    root   /var/www/majordomo;

    index  index.php index.htm index.html;

    location ~ index\.html$ {
    }

    location  fckeditor {
    }

    location ~ banner\.html$ {
    }

    location  flashcoms {
    }

    location  google {
    }

    location  fck {
    }

    location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        index  index.html index.htm index.php;
        # Uncomment to enable naxsi on this location
        # include /etc/nginx/naxsi.rules
      rewrite pda$ /popup/pda.html redirect;
        if (!-e $request_filename){
            rewrite ^(.*)$ /nf.php;
        }
        if (!-e $request_filename){
            rewrite ^(.*)$ /nf.php;
        }
    }

    location /config.php {
        deny all;
    }

    location /debmes.txt {
        deny all;
    }

    location ~ /\.ht {
        deny all;
    }

    location ~ \.php$ {
 fastcgi_pass php-fpm;
        fastcgi_index index.php;
 fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

Я использовал один из вариантов конфигурации, который нашёл на сайте разработчика. Поясню некоторые из директив.

`listen` - указывает какой адрес и порт должен прослушивать веб-сервер для получения запросов к этому сайту. При указании только номера порта, как указано в конфигурации, прослушивание будет вестись на всех доступных серверу IP-адресах. Добавление директивы default_server позволит веб серверу всегда выводить этот сайт, в том числе по запросу через IP-адрес. Если хост один, то директиву можно и не добавлять. Позже расскажу как можно разнести несколько сайтов на одном хосте.

`server_name` - доменное имя сайта. Если у вас несколько виртуальных хостов на сервере и вы не указали директиву default_server, то попасть на этот сайт вы можете только если в адресной строке вашего браузера будет указано это доменное имя. Можно также указать несколько имён через пробел, например, добавить www.majordomo.localhost.

`access_log` и `error_log` - настройка, соответственно, логов доступа на сайт и логов ошибок. Если они вам не нужны просто закомментируйте эти строки или не указывайте их совсем.

`root` - собственно указание каталога где хранится сайт.

Теперь необходимо создать файл конфигурации Majordomo. Пример такого файл есть в корне проекта `config.php.sample`. Создаём его копию `config.php`. На что необходимо обратить внимание:

* define констант с именами DB_*, это ни что иное, как реквизиты доступа к базе данных, в том числе: `DB_HOST` - хост базы данных (127.0.0.1  или localhost, скорее всего ваш вариант), `DB_NAME` - им базы данных, `DB_USER` - пользователь MySQL от имени которого будет осуществляться доступ к базе данных (указывали на этапе настройки MySQL), `DB_PASSWORD` - пароль пользователя (также указывали на этапе настройки MySQL);
* `date_default_timezone_set` - ваш часовой пояс (также необходимо настроить его в MySQL, допишу позднее);
* `define('BASE_URL', 'http://127.0.0.1:80');` - здесь вместо <http://127.0.0.1:80/> нужно указать корректный адрес, по которому демон сможет обратиться к вашему веб-сайту. Если у вас только один сайт, то можно оставить существующее значение, но если несколько виртуальных хостов, то необходимо установить корректное значение. Я установил это значение неверно и столкнулся с неработоспособностью модуля XiaomiHome. Возможно аналогичным образом работают и другие модули работы с оборудованием.

## Запускаем демона

В терминологии разработчиков Majordomo системный сервис называется циклом. По сути это системный демон написанный, также на PHP, который работает в фоне и обеспечивает выполнение текущих задач и получение информации с датчиков.

Для обеспечения автоматического запуска нужного сервиса создаём файл конфигурации для systemd: `/lib/systemd/system/majordomo.service`.

```systemd
[Unit]
Description=MajorDoMo

[Service]
Requires=mysql.service
Requires=nginx.service
Type=simple
WorkingDirectory=/var/www/majordomo
ExecStart=/usr/bin/php /var/www/majordomo/cycle.php
ExecStop=/usr/bin/pkill -f cycle_*.php
Restart=always
User=www
Group=www

[Install]
WantedBy=multi-user.target
```

Не забываем вместо www указывать того же пользователя и группу, что использовали ранее.

В список требований перед запуском сервиса указан Requires=nginx.service. Это необходимо для того, что некоторые модули, например, XiaomiHome передают данные с датчиков с помощью запросов к веб-серверу. У меня работает и без этой строки.

## Итог

После всех этих настроек мы получаем работающий сервер Majordomo. Рекомендую после проведения настроек перезагрузить сервер. Таким образом можно убедиться, что все сервисы стартуют успешно.
