# NFS

`/etc/export.d/media.conf`:

```conf
/home/fsa fd00::2(rw,sync,no_root_squash)
```

Проверить

```bash
sudo mount -t nfs "[fd00::a]:/home/fsa" /mnt/nfs/media
```

Сервис .mount:

```ini
[Unit]
Description=NFS Share

[Mount]
What=192.168.1.100:/shared_data
Where=/mnt/nfs_share
Type=nfs
Options=rw,soft,intr
TimeoutSec=30

[Install]
WantedBy=multi-user.target
```

.automount:

```ini
[Unit]
Description=Automount NFS Share

[Automount]
Where=/mnt/nfs_share
# Время простоя в секундах, после которого ресурс будет размонтирован
IdleTimeoutSec=600

[Install]
WantedBy=multi-user.target
```
