---
layout: post
title: Автоматическое монтирование дисков через systemd
date: 2023-08-28 01:57:00 +0700
tags: [Linux, systemd]
excerpt: Автоматическое монтирование файловых систем в Linux с помощью systemd.
---

```systemd
[root@lave system]# cat mnt-sdb.automount
[Unit]
Description=Automount sdb

[Automount]
Where=/mnt/sdb
TimeoutIdleSec=900

[Install]
WantedBy=multi-user.target
```

```systemd
[root@lave system]# cat mnt-sdb.mount 
[Unit]
Description=sdb mount

[Mount]
What=UUID=4d90a1eb-7dbc-4c29-a108-ed3b69508f74
Where=/mnt/sdb

[Install]
WantedBy=multi-user.target
```

```systemd
[root@lave system]# cat mnt-sda.automount 
[Unit]
Description=Automount sda

[Automount]
Where=/mnt/sda
TimeoutIdleSec=900

[Install]
WantedBy=multi-user.target
```

```systemd
[root@lave system]# cat mnt-sda.mount 
[Unit]
Description=sda mount

[Mount]
What=UUID=3c24a449-2c7e-4a8b-b41d-31a971c3b0eb
Where=/mnt/sda
Options=defaults,subvol=storage

[Install]
WantedBy=multi-user.target
```
