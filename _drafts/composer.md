# Composer

Доклад с [PHP Community meetup: 4 доклада, апдейты PHP 8.3 и итоги года](https://www.youtube.com/watch?v=JyxGieyBj3k).

SemVer
4.2.1 - MAJOR(4), Minor(2), patch(1)
^1.2 .0      is>=1.2.0   <2.0.0
~1.2 .0      is>=1.2.0   <1.3.0
^ совместимо с
~ близко к
* не рекомендуется за редким исключением

<https://jubianchi.github.io/semver-check/>

Секция require - зависимости проекта
Секция require-dev - зависимости. которые нужны при разработке проекта (PHPUnit, PHPStan и др.)

```json
"minimum-stability": "RC",
"require": {
    "psr/container": "^2.0-RC",
    "yiisoft/arrays": "^2.1@dev"
},
```

Значения Stability: dev, alpha, beta, RC.

Секция provide - заглушки для библиотек, которые могут быть заменены разными реализациями.

```json
...
"type": "library",
"require": {
...
    "psr/log": "^2.0|^3.0"
...
},
"provide": {
    "psr/log-implementation": "1.0.0"
},
```

Метапакеты:

```json
{
    "name": "smadark/log",
    "version": "1.0.0"
    "type": "metapackage",
    "require": {
	"psr/log": "^3.0",
	"yiisoft/log": "^2.0"
	"yiisoft/log-target-file": "^3.0"
    }
}
```

Platform package - виртуальные.

```json
"require": {
    "php": "^8.0",
    "ext-json": "*",
    "ext-mbstring": "*",
```

Использование * в этом случае нормально.

Указание платформы:

```json
"config": {
    "platform": {
	"php": "7.4.2"
    },
    "platform-check": true
```

## composer.lock

composer.lock фиксирует версии, которые были получены через composer up.
composer install ставит фиксированные версии из composer.lock.

composer.lock в git добавляется в приложение. В библиотеки добавлять не надо.

## Ускорение на prod

`--optimaze-autoloader` - будет построен class map, если класса в карте нет, то производится поиск по файловой системе, как обычно.

`--classmap-authoritative` - поиск классов будет производиться только в class map.

`--apcu-autoloader` - хранение в памяти.

Опции можно прописать в composer.json:

```json
"config": {
    "optimize-auytoloader": true,
```

Разделение `autoload` для prod и dev: `autoload` и `autoload-dev` в composer.json.

Исключение ненужных путей из `autoloader`

```json
"autoload": {
    "exclude-from-classmap": ["/Tests/", "/test/", "/tests/"]
}
```

## Флаги composer

`--no-dev` - не устанавливать dev зависимости (полезно для prod).

`--prefer-dist` - установка из ZIP (по умолчанию). Полезно, если в пакетах игнорируются папки докуменации, тестов и прочее.

## Репозитории

В своих пакетах можно сделать через `.gitattributes`:

```console
docs/ export-ignore
```

`satis` - генератор приватного статического репозитория для composer.

composer run запускает скрипты из composer.json:

```json
"stripts": {
    "test": [
	"Composer\\Config::disableProcessTimeout",
	"phpunit --testdox --no-interaction"
    ],
    "test-watch": "phpunit-watcher watch"
}
```

composer exec запускает скрипты из `vendor/bin`.