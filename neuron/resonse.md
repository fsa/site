---
layout: default
title: Neuron Framework - объекты response
excerpt: PHP фреймворк Neuron - объекты response
---

Группа классов, позволяющих формировать ответ на запрос. Вся группа классов наследуется от классе `FSA\Neuron\Response`, который содержит следующие методы:

* `redirection($location, $code = 302)` - выдаёт ответ HTML с кодом `$code` (по умолчанию - 302) и переадресацией по адресу `$location`, после чего завершает работу скрипта.
* `return($response)` - выдаёт $response в виде строки и завершает работу скрипта.
* `returnEmpty($code)` - выдаёт пустой ответ с кодом ответа HTML `$code`.
* `returnError($http_response_code, $message=null)` - выдаёт код ответа HTML `$http_response_code` с сообщением `$message`, либо стандартным сообщением, описывающим код ответа HTML.

## FSA\Neuron\ResponseHtml

Используется в случае, если использовался метод `App::initHtml()`.

## FSA\Neuron\ResponseJson

Используется в случае, если использовался метод `App::initJson()`.
