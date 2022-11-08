---
layout: default
title: Neuron Framework - объекты response
excerpt: PHP фреймворк Neuron - объекты response
---

## Группа классов Response

Группа классов, позволяющих формировать ответ на запрос. Вся группа классов наследуется от класса `Response`.

## Класс Response

```php
Response::redirection(
    string $location,
    int $code = 302
): never
```

Выдаёт ответ HTML с кодом `code` и переадресацией по адресу `location`.

```php
Response::return(mixed $response): never
```

Выдаёт `response` в виде строки.

```php
Response::returnEmpty(int $code): never
```

Выдаёт пустой ответ с кодом ответа HTML `code`.

```php
Response::returnError(
    int $http_response_code,
    $message = null
): never
```

Выдаёт код ответа HTML `http_response_code` с сообщением `message`, либо стандартным сообщением в соответствии с кодом ответа HTML.

## Класс ResponseHtml

Используется в случае, если использовался метод `App::initHtml()`. Имеет дополнительные методы.

## Класс ResponseJson

Используется в случае, если использовался метод `App::initJson()`. Имеет дополнительные методы.
