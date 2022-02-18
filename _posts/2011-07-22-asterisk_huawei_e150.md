---
layout: post
title: Настойка связки FreeBSD 8.2+Asterisk 1.8.5+модем Huawei E150
redirect_from:
  - /blog/huawei-E150_freebsd_asterisk/
  - /2011/07/freebsd-82asterisk-185-huawei-e150.html
date: 2011-07-22 16:07:00 +0500
tags: [Asterisk, FreeBSD, Huawei E150]
excerpt: Заметка о настройке модема Huawei E150 в качестве GSM шлюза на сервере Asterisk
---
Речь пойдёт о связке FreeBSD 8.2+Asterisk 1.8+модем Huawei E150. Цель - принимать входящие и осуществлять исходящие вызовы и принимать SMS. Модем Huawei E150 практически аналогичен модему Huawei E1550. Единственное различие - отсутствие кардридера для MisroSD-карт памяти.

Кроме непосредственно операционной системы и Asterisk необходим драйвер модема. К сожалению, найти его в портах не удалось, равно как и архива с исходным кодом, поэтому был установлен пакет devel/subversion и скачана последняя версия с сайта разработчика. Итак, проделываем следующие шаги.

```bash
cd {путь до исходных текстов}
svn checkout http://asterisk-chan-dongle.googlecode.com/svn/trunk/ asterisk-chan-dongle-read-only
asterisk-chan-dongle-read-only
./configure
gmake
gmake install
cp etc/dongle.conf /usr/local/etc/asterisk
```

Установка модема на сервер прошла успешно. Система сразу же определила несколько устройств. В том числе 4 порта COM (cuaU0.x) и CD-накопитель. Судя по этому модем можно не перепрограммировать модем если наличие виртуального CD в системе не смущает.

Настраиваем /usr/local/etc/asterisk/dongle.conf:

```ini
[general]
interval=15

[datacard0]
context=incoming-utel ; Контекст для вызовов. Должен быть описан в дайлплане.
audio=/dev/cuaU0.1    ; Порт для аудио
data=/dev/cuaU0.2     ; Порт для команд
group=1
rxgain=3
txgain=3
autodeletesms=yes
resetdatacard=yes
u2diag=0
usecallingpres=yes
callingpres=allowed_passed_screen

[datacard1]
context=incoming-motiv
audio=/dev/cuaU3.1
data=/dev/cuaU3.2
group=2
rxgain=0
txgain=0
autodeletesms=yes
resetdatacard=yes
u2diag=0
usecallingpres=yes
callingpres=allowed_passed_screen
```

Большинство параметров я взял из шаблона [datacard1]. Всё лишнее удалил.

По непонятной мне причине при первом включении оказалось 4 порта cuaU для каждого модема. Изначально было указано audio - cuaUx.2, для data cuaUx.3.

Для того, чтобы Asterisk получил доступ к портам дадим пользователю asterisk доступ к ресурсам группы dialer.

```bash
# pw usermod asterisk -G dialer
```

Дальше всё просто. Настраиваем дайлплан. Для хранения информации по дайлплану я использовал extensions.ael:

```console
context incoming-utel {
  s => {
    Set(CALLERID(all)=$[CALLERID(num)]);
    Dial(SIP/903&amp;SIP/900,60,t);
  };
  sms => {
    Verbose(Incoming SMS from ${CALLERID(num)} ${SMS});
    System(echo '${STRFTIME(${EPOCH},,%Y-%m-%d %H:%M:%S)} - ${DONGLENAME} - ${CALLERID(num)}: ${SMS}' &gt;&gt; /var/log/asterisk/sms.txt);
    Hangup();
  };
}
```

По команде Dial в моём варианте вызов будет поступать на внутренние номера 903 и 900. Кто первый ответит, тот и будет разговаривать. Замените номера своими. Естественно, здесь можно использовать все варианты команды Dial, т.е. можно отправлять вызов и на внешние направления. Всё зависит от вашей фантазии и финансов. Как правило вызовы на сеть ТфОП и сотовые телефоны не бесплатные, а платить вы будете за исходящий вызов, поэтому будьте внимательными.

Команда Set нужна для того, чтобы определялся номер звонящего на SIP-телефоне. Если эту строку удалить, то вместо номера будет указано "datacard0". Возможно вам это покажется полезным если вы планируете использовать Asterisk в качестве основы Call-центра - ваши операторы не будут видеть кто им дозванивается и не смогут игнорировать "плохих" клиентов. В любом случае узнать позже номер звонящего абонента можно в файлах CDR.

SMS принимаются и в файл /var/log/asterisk/sms.txt. Можете заманить команду echo любой командой и выполнять необходимые вам действия при приёме SMS.

Если Asterisk сообщает, что хранилище SMS переполнено:

```console
[datacard0] SMS storage is full
```

удалите все сообщения с помощью команды в консоли Asterisk:

```console
# asterisk -r
tavda*CLI> dongle cmd datacard0 AT+CMGD=1,4
```

Теперь можем проверить работоспособность входящего канала:

```console
tavda*CLI> dongle show devices
ID           Group State      RSSI Mode Submode Provider Name  Model      Firmware          IMEI      IMSI      Number        
datacard1    1     Free       18   3    3       MOTIV      E150       11.609.82.02.143  35210...  25035...  Unknown       
datacard0    1     Free       27   3    3       Utel       E150       11.609.82.02.143  35210...  25017...  +790225...
```

Если есть желание, то можно задать номер телефона для сим-карт с номером Unknown:

```console
tavda*CLI> dongle cmd datacard1 AT+CPBS=\"ON\"
tavda*CLI> dongle cmd datacard1 AT+CPBW=1,\"+795273XXXXX\",145
```

Для осуществления исходящих вызовов через модемы просто используйте соответствующие шаблоны в extensions.ael:

```console
_89022[5-7]XXXXX => Dial(Dongle/datacard0/${EXTEN});
_895304XXXXX => Dial(Dongle/datacard1/${EXTEN});
```

Вот собственно и всё. Больше ничего от модема мне не требовалось. При желании можете найти варианты настройки Asterisk для работы с модемом Huawei E1550. Настройки дайлплана для E150 будут аналогичные.

И будьте внимательны - поскольку исходящие вызовы через сотовую платные не давайте доступ к ним кому попало, а если есть доступ к серверу из интернета, пользуйтесь стойкими паролями хотя бы для тех, кто будет пользоваться исходящей связью.

P.S. Первоначальный вариант статьи от 22.12.2010 03:41 был переработан. Вместо chan_datacard теперь используется chan_dongle. Также произведён переход с FreeBSD 8.1 на 8.2 и Asterisk 1.8.0 на 1.8.5. По большей части всё описанное выше справедливо и для старых версий. Однако рекомендую при установке пользоваться свежими версиями.
