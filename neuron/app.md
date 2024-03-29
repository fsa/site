---
layout: neuron
title: Класс App
excerpt: PHP фреймворк Neuron - класс App
---

Перед началом использования фреймворка необходимо создать класс (например, `App`), который должен наследоваться от абстрактного класса `FSA\Neuron\App`.

Внутри класса необходимо объявить методы, которые, по сути, являются константами:

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
}
```

Назначение методов:

* `App::constVarPrefix()` - префикс, используемый во всех ключах Redis, используемых фреймворком;
* `App::constSessionName()` - префикс, используемый для имён Cookie, предназначенных для аутентификации пользователей, не используется, если не указана переменная окружения `SESSION_NAME`;
* `App::constSettingsFile()` - путь до [файла с настройками сайта](settings).

При необходимости, можно передать в шаблоны необходимые значения, например, имя сайта и данные сессии пользователя и другое:

```php
    protected static function getContext(): array
    {
        return [
            'title' => 'MyApp',
            'session' => self::session(),
            ...
        ];
    }
```

Если требуется дополнительная инициализация приложения, то можно переопределить метод `App::init()`, например, можно открыть подключение к системному журналу, чтобы в дальнейшем использовать команду `syslog`:

```php
    public static function init()
    {
        parent::init();
        ini_set('syslog.filter', 'raw');
        openlog('my_app', LOG_PID | LOG_ODELAY, LOG_USER);
    }
```

Шаблоны страниц располагаются в пространстве имён `Templates`. Однако эти значения можно переопределить, создав метод `App::getTemplates()`:

```php
    protected static function getTemplates(): array
    {
        return [
            \Templates\Main::class,
            \Templates\Login::class,
            \Templates\Message::class
        ];
    }
```

## Методы для работы с ответом

```php
App::init(): Response
```

Простая инициализация, если не требуется вывод. Обычно должны использоваться `App::initHtml()` или `App::initJson()`.

```php
App::initHtml(): ResponseHtml
```

Инициализация режима вывода HTML. Производит вызов `App::init()` и устанавливает перехват исключений, в результате чего любые ошибки в коде будут направляться пользователю в виде страницы с ошибкой или всплывающего окна. Метод возвращает объект [response](response), тот же, что будет возвращать `App::response()`.

```php
App::initJson(): ResponseJson
```

Инициализирует режим вывода JSON. Производит вызов `App::init()` и устанавливает перехват исключений, в результате чего ошибки в коде будут направляться в виде JSON ответа с описанием ошибки или в виде кода ошибки HTML. Метод возвращает объект [response](response), тот же, что будет возвращать `App::response()`.

```php
App::response(): Response|ResponseHtml|ResponseHTML
```

Возвращает объект [response](response), который позволяет с помощью своих методов отправлять ответы в ранее инициализированном формате.

## Методы для взаимодействия с базами данных

```php
App::sql(): PDO
```

Возвращается объект [PostgreSQL](postgresql), который является потомком PDO. Объект всегда создаётся в единственном экземпляре.

```php
App::sqlCallback(): callable
```

Возвращает объект, который можно передать в другие методы в виде функции обратного вызова, которая будет вызывать `App::sql()`. В отличии от последней, если внутри метода не происходит обращения к базе данных, то соединение с базой данной не инициализируется.

```php
App::redis(): Redis
```

Возвращается объект [RedisDB](redisdb), который является потомком Redis. Объект всегда создаётся в единственном экземпляре.

```php
App::redisCallback(): callable
```

Возвращает объект, который можно передать в другие методы в виде функции обратного вызова, которая будет вызывать `App::redis()`. В отличии от последней, если внутри метода не происходит обращения к базе данных, то соединение с базой данной не инициализируется.

## Методы для работы с сессией пользователя

```php
App::session(): Session
```

Возвращает объект [Session](session), который содержит информацию о сессии пользователя.

```php
App::login(
    string $login,
    string $password
): void
```

Позволяет начать сессию пользователя, если его `login` и `password` будут опознаны.

```php
App::logout(): void
```

Завершает текущую сессию пользователя.

## Методы для работы с настройками приложения

```php
App::getSettings(
    string $name,
    mixed $default_value = null
): mixed
```

Возвращает значение из [файла настроек](settings).

Список параметров:

* `name` - наименование раздела в файле настроек;
* `default_value` - значение, которое будет возвращено, если заданного пункта в настройках не нашлось.

## Методы для работы с переменными приложения

Сохранение производится в базе данных Redis. Каждая переменная получает префикс приложения.

```php
App::setVar(
    string $name,
    mixed $value
): bool
```

Сохраняет значение переменной.

Возвращает `true` в случае успеха, или `false` при возникновении ошибок.

Список параметров:

* `name` - имя переменной;
* `value` - значение переменной.

```php
App::getVar($name): string|bool
```

Возвращает значение переменной, установленной через `App::setVar`. В случае возникновения ошибки может вернуть `false`.

```php
App::setVarJson(
    string $name,
    mixed $value
): bool
```

Аналогично `App::setVar`, но при сохранении значения производится JSON-кодирование входных данных.

```php
App::getVarJson(string $name): mixed
```

Аналогично `App::getVar`, но полученное значение обрабатывается функцией `json_decode`.

```php
App::delVar(string $name): int
```

Удаляет значение переменной. Возвращает количество удалённых ключей.
