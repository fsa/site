---
layout: post
title: Microcosm и переход с lighttpd на nginx
date: 2012-03-20 18:29:00 +0500
tags: [Microcosm, nginx, OpenStreetMap]
excerpt: Создание собственного локального сервера OpenStreetMap на базе Microcosm
---
Решил я заменить lighttpd на nginx. Уж очень часто его нахваливают в интернете. Всё прошло гладко. Но споткнулся о небольшое приложение для хранения геоданных - [Microcosm](http://wiki.openstreetmap.org/wiki/Microcosm). Написано оно на php. В документации есть только вариант для Apache:

```apache
# BEGIN Microcosm
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /api/
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /m/microcosm.php [L]
</IfModule>

# END Microcosm
```

В lighttpd настройка была ещё проще:

```console
url.rewrite = ( "^/api/(.*)$" => "m/microcosm.php/$1" )
```

С nginx получилось немного сложнее:

```nginx
location /api/ {
   fastcgi_pass unix:/var/spool/php-fpm.socket; # PHP-FPM socket
   root   /home/web/htdocs/m/; # Microcosm directory
   fastcgi_index microcosm.php;
   include        fastcgi_params;
   fastcgi_split_path_info ^(\/api)(.*)$;
   fastcgi_param SCRIPT_FILENAME $document_root/microcosm.php;
   fastcgi_param PATH_INFO $fastcgi_path_info;
}
```

Используется директива `fastcgi_split_path_info`. Она разбивает адресную строку запроса на 2 части, которые описаны регулярными выражениями. Первая часть — это `/api`, попадает в переменную `$fastcgi_script_name`. Вторая часть попадает в `$fastcgi_path_info`. Её и скармливаем php в виде `$_SERVER['PATH_INFO']`. Эта переменная и используется в microcosm.
