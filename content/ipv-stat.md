---
title: Сбор статистики по протоколам IPv4 и IPv6
date: 2026-06-03 16:52:00 +0700
tags: [IPv6, CLAT, NAT64, XLAT, nftables]
description: Попытка собрать статистику по распределению трафика на отдельно взятой машине.
---
В данный момент эта заметка — черновик. В настоящее время эти скрипты и конфигурации выдают неточную информацию. Используйте этот код только если сами понимаете как он работает или для написания своего варианта. Если есть предложения, присылайте свои изменения на электронную почту.

Этот код должен выдавать статистику использования IPv4/IPv6 трафика, а также трафика, который адресован NAT64.

```nftables
table inet clat_traffic_stats {

    # Именованные счетчики трафика
    counter c_in_pure_v6  { comment "Входящий чистый IPv6" }
    counter c_in_nat64    { comment "Входящий NAT64" }
    counter c_in_pure_v4  { comment "Входящий нативный IPv4" }

    counter c_out_pure_v6 { comment "Исходящий чистый IPv6" }
    counter c_out_nat64   { comment "Исходящий NAT64 (до упаковки в eBPF)" }
    counter c_out_pure_v4 { comment "Исходящий нативный IPv4" }

    # 1. ВХОДЯЩИЙ ТРАФИК (Хук prerouting)
    chain clat_in {
        type filter hook prerouting priority filter; policy accept;

        # NetworkManager CLAT выдает приложениям IPv4-адрес из диапазона RFC 7335 (192.0.0.0/29).
        # Если входящий пакет имеет адрес назначения из этого диапазона, значит он пришел
        # из сети как NAT64 (IPv6) и eBPF его успешно распаковал.
        ip daddr 192.0.0.0/29 counter name c_in_nat64 accept

        # Нужно выяснить на каком этапе перехватывается пакет использовать либо предыдущий
        # фильтр, либо этот, либо вообще переделать логику
        ip6 saddr 64:ff9b::/96 counter name c_in_nat64 accept

        # Если пакет IPv6 (после прохода eBPF он остался IPv6) — это чистый IPv6
        meta nfproto ipv6 counter name c_in_pure_v6 accept

        # Любой другой IPv4 пакет (пришедший в обычных Wi-Fi сетях) — нативный IPv4
        meta nfproto ipv4 counter name c_in_pure_v4 accept
    }

    # 2. ИСХОДЯЩИЙ ТРАФИК (Хук output)
    chain clat_out {
        type filter hook output priority filter; policy accept;

        # Если приложение само сформировало пакет на IPv6-префикс NAT64 напрямую
        ip6 daddr 64:ff9b::/96 counter name c_out_nat64 accept

        # Обычный исходящий IPv6 (не NAT64)
        meta nfproto ipv6 counter name c_out_pure_v6 accept

        # Если приложение отправляет IPv4 с CLAT-адреса (RFC 7335) — это будущий NAT64,
        # который eBPF CLAT через мгновение упакует в IPv6
        ip saddr 192.0.0.0/29 counter name c_out_nat64 accept

        # Любой другой исходящий IPv4 (в сетях с честным Dual-Stack или IPv4-only)
        meta nfproto ipv4 counter name c_out_pure_v4 accept
    }
}
```

Просмотр статистики

```bash
#!/bin/bash

# Читаем JSON один раз в переменную, чтобы не вызывать nft многократно
JSON_DATA=$(sudo nft -j list table inet clat_traffic_stats)

# Функция для получения байт по имени счетчика
get_bytes() {
    echo "$JSON_DATA" | jq ".nftables[] | select(.counter.name == \"$1\") | .counter.bytes"
}

echo "=== ТРАФИК ИЗ СЕТИ (ВХОДЯЩИЙ) ==="
echo "Чистый IPv6: $(get_bytes c_in_pure_v6) байт"
echo "NAT64 / CLAT: $(get_bytes c_in_nat64) байт"
echo "Нативный IPv4: $(get_bytes c_in_pure_v4) байт"
echo ""
echo "=== ТРАФИК В СЕТЬ (ИСХОДЯЩИЙ) ==="
echo "Чистый IPv6: $(get_bytes c_out_pure_v6) байт"
echo "NAT64 / CLAT: $(get_bytes c_out_nat64) байт"
echo "Нативный IPv4: $(get_bytes c_out_pure_v4) байт"
```

Сброс счётчиков:

```bash
nft reset counters table inet clat_traffic_stats
```

Известные проблемы:

1. Странно работает счётчик входящих для CLAT. Не работает при дуалстеке, хотя трафик есть, но работает в режиме IPv6only.
2. Нужно проверить логику фильтров счётчиков, чтобы они работали с правильными данным (до eBPF или после). Это влияет на пункт 1.
3. По хорошему, трафик CLAT нужно вычислять по его маркировке программой трансляции.
