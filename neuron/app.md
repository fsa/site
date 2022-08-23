---
layout: default
title: Neuron Framework
excerpt: PHP фреймворк Neuron - класс App
---

Перед началом использования фреймворка необходимо создать класс (например, `App`), который должен наследоваться от абстрактного класса `FSA\Neuron\App`.

Внутри класса необходимо объявить константы

```php
class App extends FSA\Neuron\App
{
    const REDIS_PREFIX = 'my_app';
    const LOG_TAG = 'my_app';
    const SESSION_NAME = 'my_app';
    const SETTINGS_FILE = __DIR__ . '/../settings.php';
}
```

* REDIS_PREFIX - префикс, используемый во всех ключах Redis, используемых фреймворком;
* LOG_TAG - тег для журнала, используется в команде openlog и позволяет фильтровать сообщения в журнале, созданные syslog, с помощью этого тега (`journalctl -t my_app...`);
* SESSION_NAME - префикс, используемый для имён Cookie, предназначенных для аутентификации пользователей, если не указана переменная окружения `SESSION_NAME`;
* SETTINGS_FILE - путь до [файла с настройками сайта](settings).

Рекомендуется переопределить метод App::initHtml() и явно задать используемые шаблоны для веб-страниц. Кроме этого, можно передать во все эти шаблоны необходимые параметры через метод setContext(), который принимает массив параметров. В том числе можно передать в шаблон динамические данные, например, данные сессии пользователя.

```php
public static function initHtml($main_template = Templates\Main::class, $login_template = Templates\Login::class, $message_template = Templates\Message::class): FSA\Neuron\ResponseHtml
{
    parent::initHtml($main_template, $login_template, $message_template);
    self::$response->setContext(['title' => 'MyApp', 'session' => self::session()]);
    return self::$response;
}
```
