# Xray

Это пример установки и настройки VLESS. `Xray` и `sing-box` позволяют настраивать различные конфигурации. В данной заметке приведён пример настройки одной из таких конфигураций.

## Сборка Xray-core

Собрать Xray-core можно скачав из [git-репозитория](https://github.com/XTLS/Xray-core). Команда для сборки есть в `README.md`. Например, для сборки под Linux/macOS:

```bash
CGO_ENABLED=0 go build -o xray -trimpath -buildvcs=false -ldflags="-s -w -buildid=" -v ./main
```

После выполнения команды будет создан исполняемый файл `xray`. Его необходимо переместить в удобное для вас место, например, `/opt/`.

Для обеспечения автозагрузки сервиса необходимо создать systemd юнит, например, `xray.service`:

```systemd
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=xray
Group=xray
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/opt/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
```

В качестве имени пользователя и группы указаны `xray`. Необходимо создать такого пользователя или указать своего. Файл конфигурации должен быть расположен в файле `/etc/xray/config.json` (это указано в ранее в файле xray.service). Прежде чем создавать файл необходимо создать случайно сгенерированные параметры:

```bash
xray uuid
xray x25519
```

Первая команда сгенерирует уникальный UUID, вторая создаст публичный и закрытый ключ. Теперь можно создать файл `/etc/xray/config.json`.

```json
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 443, 
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "UUID",// uuid
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "dest": "EXAMPLE.COM:443",// сайт заглушка
                    "serverNames": [
                        "EXAMPLE.COM",// сайт заглушка
                        "WWW.EXAMPLE.COM"// и альтернативные имена, при желании
                    ],
                    "privateKey": "PRIVATE_KEY",  // Private key
                    "shortIds": [   
                        "0a381e1fa219",// Список уникальных коротких идентификаторов
                        "be0ce04754dc"
                    ]
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
```

`shortIds` представляют из себя уникальные идентификаторы клиентов длиной от 2 до 16 символов. Используются только символы от `0` до `9` и от `a` до `f`. Можно сгенерировать, например, командой

```bash
openssl rand -hex 8
```

## Создание конфигурации для клиента

Для клиентов на мобильных устройствах, например, `v2rayNG` для Android можно создать ссылку для настройки конфигурации:

```console
vless://<UUID>@<SERVER_ADDR>:443?type=tcp&security=reality&pbk=<PUBLIC_KEY>&fp=chrome&sni=<FAKE_DOMAIN>&sid=<SHORT_ID>&flow=xtls-rprx-vision#<NAME>
```

Параметры:

- UUID — соответствующий параметр из файла конфигурации сервера;
- SERVER_ADDR — IP адрес или доменное имя сервера;
- PUBLIC_KEY — публичный ключ, который был сгенерирован перед созданием файла конфигурации сервера;
- FAKE_DOMAIN — доменное имя из секции `serverNames` конфигурации, будет использовано в TLS соединении в секции SNI, указанный сервер должен поддерживать TLSv1.3;
- SHORT_ID — один из идентификаторов из секции `shortIds`;
- NAME — желаемое имя конфигурации после импорта в клиента.

Для передачи на клиента можно использовать QR-код. Его, например, можно создать прямо в консоли. Для этого нужно сохранить ссылку в файл `client_config.url`. Не забудьте предварительно установить пакет `qrencode`, если в Ubuntu/Debian и Fedora в основных репозиториях.

```bash
qrencode -t ansiutf8 < client_config.url
```

## Конфигурация Xray на клиенте

Собираем xray на клиенте аналогично как и на сервере. Пример конфигурации в качестве клиента приведён ниже.

```json
{
    "log": {
        "level": "info"
    },
    "routing": {
        "rules": [
            {
                "type": "field",
                "domain": [
                    "2ip.ru",
                    "2ip.io"
                ],
                "outboundTag": "direct"
            }
        ]
    },
    "inbounds": [
        {
            "listen": "::",
            "port": 1080,
            "protocol": "socks",
            "settings": {
            "udp": true
        },
        "sniffing":
            {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls",
                    "quic"
                ],
                "routeOnly": true
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "vless",
            "settings": {
            "vnext": [
                {
                    "address": "MY_SERVER",
                    "port": 443,
                    "users": [
                        {
                            "id": "UUID",
                            "encryption": "none",
                            "flow": "xtls-rprx-vision"
                        }
                    ]
                }
            ]
        },
        "streamSettings": {
        "network": "tcp",
        "security": "reality",
                "realitySettings": {
                    "fingerprint": "chrome",
                    "serverName": "EXAMPLE.COM",
                    "publicKey": "PUBLIC_KEY",
                    "shortId": "0a381e1fa219"
                }
            },
            "tag": "proxy"
        },
        {
            "protocol": "freedom",
            "tag": "direct"
        }

    ]
}
```

Секция `"routing"` не обязательная. С её помощью можно перенаправлять определённые домены на определённые прокси или без используя теги объектов из `"outbounds"`.

## Конфигурация sing-box

В качестве клиента для Linux можно использовать `sing-box`. Например, чтобы можно создать socks прокси для локальной машины или локальной сети:

```json
{
    "log": {
        "level": "info"
    },
    "inbounds": [
        {
            "type": "socks",
            "tag": "socks-in",
            "listen": "::",
            "listen_port": 1080
        }
    ],
    "outbounds": [
        {
            "type": "vless",
            "server": "SERVER_ADDR",
            "server_port": 443,
            "uuid": "UUID",
            "flow": "xtls-rprx-vision",
            "tls": {
                "enabled": true,
                "insecure": false,
                "server_name": "EXAMPLE.COM",
                "utls": {
                    "enabled": true,
                    "fingerprint": "chrome"
                },
                "reality": {
                    "enabled": true,
                    "public_key": "PUBLIC_KEY",
                    "short_id": "SHORT_ID"
                }
            }
        }
    ]
}
```

Параметры настройки аналогичные используемым в файле настройки сервера и конфигурации клиента для мобильных устройств.
