---
layout: post
title: SSH
date: 2023-05-18 23:15:00 +0700
tags: [SSH]
excerpt: Небольшая заметка о том, что можно делать с помощью SSH.
published: false
---

Запуск с произвольным файлом hosts с указанием переменной, в данном случае пароле для sudo:

```bash
ansible-playbook -i test.ini upgrade.yml -e "ansible_become_password=PaSsWoRd"
```

Используемый пользователь при подключении, ввести пароль пользователя и пароль для поднятия привилегий для sudo

```bash
ansible-playbook -i test.ini upgrade.yml --user fsa --ask-pass --ask-become-pass 
```

Переменные

```ini
ansible_user=osboxes
```

Пароль пользователя при подключении

```ini
ansible_password=osboxes.org
```

Пароль sudo для пользователя

```ini
ansible_sudo_pass=osboxes.org
```

Запуск скрипта на определённой машине (`era`):

```bash
ansible-playbook -l era upgrade.yml
```

Добавление нового пользователя на машину, где есть доступ root по ключу

```bash
ansible-playbook -i leona,era2 useradd.yml -e "ansible_user=root"
```
