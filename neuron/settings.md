---
layout: default
title: Neuron Framework - файл настроек
excerpt: PHP фреймворк Neuron - файл настроек
---

Файл настроек - это обычный PHP файл, который должен возвращать массив с данными. Извлечение данных производится из массива по ключу. Ключ может содержать любые данные, поскольку их обработкой занимается пользовательский код.

Для получения данных из файла используется метод `App::getSettings($name, $default_value)`, где `$name` - имя параметра, `$default_value` - значение по умолчанию, если параметр отсутствует в файле настроек, по умолчанию `null`.

Файл настроек может быть расположен в любом месте файловой системы. Путь до файла необходимо указать в основном классе вашего проекта [App](app).

Пример файла настроек:

```php
<?php
return [
    'my_key' => 'super_password',
    'my_data' => (object)[
        'a' => 'Param a',
        'b' => 'Param b'
    ]
];
```

Получение данных из файла:

```php
$key = App::getSettings('my_key');
echo $key . PHP_EOL; # super_password
$data = App::getSettings('my_data');
echo $data->a . PHP_EOL; # Param a
echo $data->b . PHP_EOL; # Param b
```