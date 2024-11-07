# Wireguard в netns

Запуск туннеля Wireguard внутри пространства имён `vpn`:

```bash
ip link add wg0 type wireguard
ip link set wg0 netns vpn
ip -n vpn addr add 192.168.2.2/32 dev wg0
ip netns exec vpn wg setconf wg0 /etc/wireguard/wg0.conf 
ip -n vpn link set wg0 up
ip -n vpn route add default dev wg0
ip netns exec vpn sudo -u USER firefox
```

Файл конфигурации /etc/wireguard/wg0.conf

```ini
[Interface]
PrivateKey = PRIVATE_KEY
ListenPort = 50123

[Peer]
PublicKey = PEER_PUBLIC_KEY
PresharedKey = PRESHARED_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = endpoint.example.org:51820
PersistentKeepalive = 60
```

ListenPort выбрать, чтобы не совпадал с другими Wireguard в этой сети.
