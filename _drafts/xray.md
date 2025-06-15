# Xray

```bash
xray uuid
xray x25519
```

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
                        "id": "",// uuid
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "dest": "example.com:443",// сайт заглушка
                    "serverNames": [
                        "example.com",// сайт заглушка
                        "www.example.com"// и альтернативные имена
                    ],
                    "privateKey": "",  // Private key
                    "shortIds": [   
                        "0a381e1fa219",// Список уникальных коротких идентификаторов, доступных клиентам, чтобы их различать
                        "be0ce04754dc",// Длина: от 2 до 16 символов. Используемые символы: 0-f. 
                        "41beec74f4bc"// Для удобства, значения можно сгенерировать командой `openssl rand -hex 6`
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

```console
vless://<uuid>@<IP-адрес сервера>:443?type=tcp&security=reality&pbk=<публичный ключ>&fp=chrome&sni=<домен из serverNames в конфиге>&sid=<одно из значений shortIds в конфиге>&flow=xtls-rprx-vision#<имя соединения>
```

```bash
qrencode -t ansiutf8 < client_config.txt
```

Сборка

```bash
CGO_ENABLED=0 go build -o xray -trimpath -buildvcs=false -ldflags="-s -w -buildid=" -v ./main
```
