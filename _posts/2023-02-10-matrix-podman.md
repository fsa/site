---
layout: post
title: Установка сервера Matrix Synapse
date: 2023-02-10 04:58:00 +0700
tags: [Matrix, Synapse, Podman]
excerpt: Статья по установке и настройке собственного Matrix сервера с помощью системы контейнеризации Podman
---
Эта заметка поможет вам установить свой собственный сервер сети Matrix в контейнере. О том, что такое Matrix и установке сервера без использования контейнеров [я писал ранее](/matrix). Если вы не знакомы с Matrix, рекомендую ознакомиться с предыдущей заметкой.

К тому моменту, как вы начнёте устанавливать свой сервер необходимо определиться с именем домена, т.к. он понадобится при запуске Matrix Synapse. В этой заметке в качестве этого домена будет использоваться example.org. В реальной жизни, если вам необходима федерация, необходимо приобрести домен.

В качестве образа для контейнера Matrix Synapse выберем официальный образ от разработчиков `docker.io/matrixdotorg/synapse`. Скачать его можно с помощью команды

```bash
podman pull matrixdotorg/synapse
```

Synapse может работать с базой SQLite, но использовать её можно, скорее, только для тестирования. Если вы собираетесь выводить ваш сервер в интернет, можете столкнуться с проблемами даже на самых ранних этапах. Поэтому лучше изначально использовать базу PostgreSQL. Можно использовать любой доступный образ для него. Выберем официальный образ `docker.io/library/postgres:15-alpine`.

```bash
podman pull postgres:15-alpine
```

## Создание Pod для сервера Matrix Synapse

Все необходимые контейнеры для сервера Synapse разместим в pod с именем synapse. Сервер будет прослушивать порт 8008 без использования TLS. Создать pod можно командой

```bash
podman pod create --name matrix -p 8008:8008
```

После этого можно проверить его наличие с помощью команды

```console
[~]$ podman pod list                              
POD ID        NAME        STATUS      CREATED        INFRA ID      # OF CONTAINERS
707397d2f7c2  matrix      Created     2 seconds ago  74de2d35e7ab  1
```

## Создание контейнера с PostgreSQL

Создаём базу данных, при этом вместо `SUPER_PASSWORD` указываем сложный пароль для доступа к базе данных, который в дальнейшем необходимо будет добавить в конфигурацию сервера synapse.

```bash
podman run -d -it --pod matrix --name synapse-db \
    -e POSTGRES_USER=synapse \
    -e POSTGRES_PASSWORD=SUPER_PASSWORD \
    -e "POSTGRES_INITDB_ARGS=--encoding=UTF-8 --lc-collate=C --lc-ctype=C" \
    -v synapse_db_data:/var/lib/postgresql/data:Z \
    docker.io/library/postgres:15-alpine
```

Если необходимо что-то изменить в базе данных можно подключиться к контейнеру с PostgreSQL

```bash
podman exec -it synapse-db /bin/bash
```

а затем запустить оболочку psql. При запуске требуется ввести пароль, который был установлен ранее при создании контейнера с PostgreSQL.

```bash
psql -U synapse -W
```

## Создание контейнера с Synapse и его настройка

Перед запуском контейнера с Synapse необходимо создать конфигурацию для него. Для создания образца файла можно создать одноразовый контейнер с аргументом generate. При этом необходимо указать минимум два параметра: `SYNAPSE_SERVER_NAME` - доменное имя вашего сервера и `SYNAPSE_REPORT_STATS` - ваше желание сообщать или нет статистику по вашему серверу разработчикам.

```bash
podman run -it --rm --mount type=volume,src=synapse-data,dst=/data \
    -e SYNAPSE_SERVER_NAME=example.org \
    -e SYNAPSE_REPORT_STATS=yes \
    matrixdotorg/synapse generate
```

В результате будет создана конфигурация примерно следующего содержания:

```yaml
server_name: "example.org"
pid_file: /data/homeserver.pid
listeners:
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    resources:
      - names: [client, federation]
        compress: false
database:
  name: sqlite3
  args:
    database: /data/homeserver.db
log_config: "/data/example.org.log.config"
media_store_path: /data/media_store
registration_shared_secret: "R_S_SECRET"
report_stats: true
macaroon_secret_key: "MACAROON_SECRET_KEY"
form_secret: "FORM_SECRET"
signing_key_path: "/data/example.org.signing.key"
trusted_key_servers:
  - server_name: "matrix.org"
```

Изменяем настройки соединения с базой данных. В качестве `host` указываем наименование контейнера с PostgreSQl.

```yaml
database:
  name: psycopg2
  txn_limit: 10000
  args:
    user: synapse
    password: SUPER_PASSWORD
    database: synapse
    host: synapse-db
    port: 5432
    cp_min: 5
    cp_max: 10
```

После этого можно запустить контейнер с synapse:

```bash
podman run -d -it --pod matrix --name synapse \
    --mount type=volume,src=synapse-data,dst=/data \
    matrixdotorg/synapse:latest
```

Создание новых пользователей на сервере отключено по умолчанию. Поэтому чтобы создать сервер подключимся к контейнеру с Synapse:

```bash
podman exec -it synapse /bin/bash
```

Зарегистрируем нового пользователя:

```console
root@synapse:/# register_new_matrix_user -c /data/homeserver.yaml http://localhost:8008
New user localpart [root]: fsa
Password: 
Confirm password: 
Make admin [no]:
Sending registration request...
Success!
```

Теперь сервер прослушивает порт 8008.

Продолжение следует...

## Список литературы

1. <https://matrix-org.github.io/synapse/latest/setup/installation.html>

2. <https://matrix.org/docs/guides/understanding-synapse-hosting>
