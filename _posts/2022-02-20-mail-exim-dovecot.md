---
layout: post
title: Настройка почтового сервера
date: 2022-02-15 22:25:00 +0700
tags: [Email, postfix, dovecot]
excerpt: Заметка об установке почтового сервера на базе ПО dovecot и postfix
published: false
---
Почтовые протоколы одни из первых протоколов обмена данными. Они обеспечивают обмен сообщениями между пользователями с использованием почтовых серверов. Например, первое RFC для протокола SMTP датируется 1982 годом.

Для своего почтового сервера требуется несколько компонентов:

1. база данных пользователей;
2. сервис для отправки и пересылки почты;
3. сервис для получения почты.

Установка имени хоста и соответствующих PTR записей.

apt install dovecot-core dovecot-pop3d

imapd ставится по умолчанию

apt install dovecot-lmtpd

10-mail.conf

```ini
mail_location = maildir:/var/mail/%d/%n
```

## SPF

RFC 7208 (взамен устаревшего RFC 4408). RFC 8616 - дополнение для интернациональных имён. RFC 8553 - узлы с подчёркиванием в имени.

Просто запись в DNS

## DKIM [RFC6376]

Криптографический подписи

```bash
apt install opendkim opendkim-tools
opendkim-genkey -D /etc/dkimkeys/ -d $(hostname -d) -s $(hostname)
chgrp opendkim /etc/dkimkeys/*
chmod g+r /etc/dkimkeys/*
gpasswd -a postfix opendkim
```

opendkim
```ini
#Socket   local:/run/opendkim/opendkim.sock
Socket   local:/var/spool/postfix/opendkim/opendkim.sock
```

```bash
sudo mkdir -p /var/spool/postfix/opendkim
sudo chown opendkim:opendkim /var/spool/postfix/opendkim
```

```diff
< Canonicalization relaxed/relaxed
---
> Canonicalization relaxed/simple
23d22
< Domain   fsa.su
25d23
< Selector  mx
27d24
< KeyFile  /etc/dkimkeys/example.private
40c37
< #Socket   local:/run/opendkim/opendkim.sock
---
> Socket   local:/run/opendkim/opendkim.sock
43c40
< Socket   local:/var/spool/postfix/opendkim/opendkim.sock
---
> #Socket   local:/var/spool/postfix/opendkim/opendkim.sock
```

## DMARC [RFC7489]
