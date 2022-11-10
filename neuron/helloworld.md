---
layout: neuron
title: Hello, World!
excerpt: PHP фреймворк Neuron, первые шаги
---

## Что такое Neuron Framework?

Neuron - это PHP фреймворк, который был создан на основании моего опыта разработки на PHP. Фреймворк позволяет создавать веб-приложения, которые могут взаимодействовать с СУБД PostgreSQL и Redis.

Подробнее о том, что умеет фреймворк:

* механизм шаблонов HTML на чистом PHP (генерация страниц, окна входа в систему и сообщений для пользователей);
* аутентификация и авторизация пользователей (требуется PostgreSQL);
* сессии пользователей через встроенную систему или через внешние системы аутентификации (требуется Redis);
* механизмы для построения API с использованием JSON;
* упрощение взаимодействия с PostgreSQL и Redis, поддержание единственного соединения с БД;
* вспомогательные механизмы для маршрутизации запросов, отображения данных из SQL.

## Создание «Hello, World!»

Для начала использования фреймворка подключите его к вашему проекту с помощью composer:

```bash
composer require fsa/neuron-framework
```

Все классы фреймворка расположены в пространстве имён `FSA\Neuron`. Для начала использования фреймворка создайте [класс App](app). Например:

```php
class App extends FSA\Neuron\App
{
    protected static function constVarPrefix(): string
    {
        return "my_app";
    }

    protected static function constSessionName(): string
    {
        return "my_app";
    }

    protected static function constSettingsFile(): string
    {
        return __DIR__ . '/../settings.php';
    }

    protected static function getContext(): array
    {
        return [
            'title' => 'MyApp'
        ];
    }
}
```

Создадим шаблон для страниц сайта `\Templates\Main`:

```php
<?php

namespace Templates;

class Main
{

    public $title;
    public $context;
    public $header;
    public $notify;

    public function showHeader()
    {
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title><?=is_null($this->title)?$this->context['title']:$this->title.' :: '.$this->context['title']?></title>
<?=$this->header?>
</head>
<body>
<?php
    }

    public function showFooter()
    {
?>
</body>
</html>
<?php
    }

    public function showPopup($message, $title, $style = null)
    {
        echo "<p>$message</p>";
    }
}
```

Создадим страницу, отображающую «Hello, World!».

```php
<?php

require_once '../../vendor/autoload.php';
$response = App::initHtml();
$response->addDescription('«Hello, World!» page.');
$response->showHeader();
echo "<p>Hello, World!!!</p>";
$response->showFooter();
```
