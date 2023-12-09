# Symfony

Создание проекта

```bash
composer create-project symfony/skeleton:"7.0.*" ИМЯ_ПРОЕКТА
```

Установка сервиса логирования

```bash
composer require logger
```

Будет установлен `symfony/monolog-bundle`

Настроить лог в journald, для примера в dev окружении

```yaml config/packages/monolog.yaml
when@dev:
    monolog:
        handlers:
            main:
                type: syslog
                ident: shcc
                level: debug
                channels: ["!event"]
```

Установка PHPUnit и Browser Kit для тестирования, второй нужен для тестирования контроллеров

```bash
composer require phpunit/phpunit --dev
composer require symfony/browser-kit --dev
```

Установка утилита для создания шаблонного кода

```bash
composer require --dev symfony/maker-bundle
```

Установка доктрины

```bash
composer require doctrine/doctrine-bundle
```

Вопрос кодировки БД перед созданием базы!!!

Если нужен ORM. Нужен для создания Entity.

```bash
composer require doctrine/orm
```

Для создания миграций

```bash
composer require doctrine/doctrine-migrations-bundle
```

Создание миграции

```bash
bin/console make:migration
```

Запуск миграции

```bash
bin/console doctrine:migrations:migrate
```

Нужен ли?
composer require opensoft/doctrine-postgres-types

Профилировщик

composer require --dev symfony/profiler-pack

Настройка security
<https://symfony.com/doc/current/security.html>
<https://symfony.com/doc/current/security/remember_me.html>
<https://symfony.com/doc/current/session.html>

Создание контроллера

bin/console make:controller Login

composer require symfony/webpack-encore-bundle
npm install

composer require symfony/webpack-encore-bundle
npm install bootstrap --save-dev
npm install sass-loader@^13.0.0 sass --save-dev
