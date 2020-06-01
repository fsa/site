---
layout: post
title: Настройка модема Huawei E150 в Ubuntu
date: 2010-09-23 05:05:00 +0500
categories: доступ в интернет, Huawei E150, Ubuntu
---
К сожалению, установка модема Huawei E150 в Ubuntu у меня прошло не очень гладко. Изначально модем не определялся. Для корректной работы модема требуется установить пакет usb-modeswitch. Вот тут, к сожалению, требуется доступ к интернету. Итак, выполняем:</p>
```bash
$ sudo apt-get install usb-modeswitch
```
Далее можно подключить модем и пощупать устройства. Показываю на своём примере:</p>
```bash
fsa@fsa-laptop:~$ lsusb 
Bus 006 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 005 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 004 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 003 Device 006: ID 12d1:1446 Huawei Technologies Co., Ltd. 
Bus 003 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 002 Device 003: ID 04f2:b071 Chicony Electronics Co., Ltd 2.0M UVC Webcam / CNF7129
Bus 002 Device 002: ID 058f:6366 Alcor Micro Corp. Multi Flash Reader
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```
Как видим, наш модем успешно опознан, но до сих пор не работает. Объясняем системе что делать с устройством:
```bash
sudo modprobe usbserial vendor=0x12d1 product=0x1446
```
Значения полей vendor и продукт копируем из вывода команды lsusb.

Но и после этих действий у меня модем не опознался. Решение было простое - вытащить модем и снова его подключить. Всё! Модем готов "к труду и обороне"! Дальше в несколько кликов в network-manager выбираем наш модем и оператора, симка которого у нас установлена, и вы в сети. Кстати, на выбор имеются даже такие экзотические сотовые операторы как у нас: Мотив и Ютел. Ютел работает точно, для Мотива настройки проверял - всё верно!
