---
layout: post
title: Сетевые пространства имён и Wireguard
date: 2024-11-08 11:50:00 +0700
tags: [VPN, Wireguard]
excerpt: Шпаргалка по настройке VPN на базе Wireguard с использованием сетевых пространств имён
---
В этой заметке рассматривается вопрос как разместить на своём домашнем компьютере какой-нибудь сервер таким образом, чтобы весь трафик на него проходил через VPN от арендованного VPS сервера, но при этом все остальные программы на компьютере работали по прежнему напрямую, без использования VPN. В этом могут помочь сетевые пространства имён.

Запуск туннеля Wireguard внутри пространства имён `vpn`:

```bash
ip netns add vpn
ip link add wg0 type wireguard
ip link set wg0 netns vpn
ip -n vpn addr add 192.168.2.2/32 dev wg0
ip netns exec vpn wg setconf wg0 /etc/wireguard/wg0.conf 
ip -n vpn link set wg0 up
ip -n vpn route add default dev wg0
```

Файл конфигурации аналогичен wg-quick, но в нём не поддерживаются некоторые опции. Пример файла конфигурации `/etc/wireguard/wg0.conf`:

```ini
[Interface]
PrivateKey = PRIVATE_KEY
ListenPort = 50123

[Peer]
PublicKey = PEER_PUBLIC_KEY
PresharedKey = PRESHARED_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = endpoint.example.org:51820
# Необходимо для поддержания соединения через NAT
PersistentKeepalive = 60
```

ListenPort по умолчанию будет использоваться такой же, как на стороне Peer. Лучше его указать вручную и выбирать таким, чтобы он не совпадал с другими Wireguard, которые могут быть запущены в той же локальной сети и будут пользоваться тем же самым шлюзом NAT, если, конечно, он используется.

Осталось решить ещё один вопрос с DNS. Для него требуется файл resolve.conf, который обычно расположен в `/etc/resolve.conf`. Однако для сетевых пространств имён его необходимо разместить в папке `/etc/netns/vpn/`, где `vpn` — указанное ранее имя пространства. Например `/etc/netns/vpn/resove.conf`:

```conf
nameserver 1.1.1.1
nameserver 1.0.0.1
```

Укажите свои серверы имён, которые используете в VPN соединении.

Теперь можно запустить, например, `firefox` в пространстве имён от имени пользователя и убедиться, что доступ в интернет есть и сервисы определения IP показывают IP адрес вашей VPS:

```bash
ip netns exec vpn sudo -u USER firefox
```

## Что на счёт IPv6?

IPv6 настраивается аналогично. Здесь для примера взят интерфейс `wg1` в пространстве `vpn6`:

```bash
ip netns add vpn6
ip link add wg1 type wireguard
ip link set wg1 netns vpn6
ip -n vpn6 addr add 2001:db0::2/128 dev wg1
ip netns exec vpn6 wg setconf wg1 /etc/wireguard/wg1.conf 
ip -n vpn6 link set wg1 up
ip -n vpn6 route add default dev wg1
```

Файл конфигурации `/etc/wireguard/wg1conf`:

```ini
[Interface]
PrivateKey = PRIVATE_KEY
ListenPort = 50124

[Peer]
PublicKey = PEER_PUBLIC_KEY
PresharedKey = PRESHARED_KEY
AllowedIPs = 2000::/3
# Необходимо только если используется NAT64 на 64:ff9b::/96
AllowedIPs = 64:ff9b::/96
Endpoint = endpoint.example.org:51820
# Необходимо для поддержания соединения через NAT
PersistentKeepalive = 60
```

При желании можно также поднять NAT64 на VPS сервере, тогда в туннеле будет ходить трафик исключительно IPv6.
Для того, чтобы трафик до IPv4 серверов начал ходить через NAT64 укажите адрес вашего DNS64 сервера или какие-либо публичные серверы, если вы используете диапазон `64:ff9b::/96`, например, cloudflare:

```conf
nameserver 2606:4700:4700::64
nameserver 2606:4700:4700::6464
```
