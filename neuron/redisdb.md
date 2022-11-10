---
layout: neuron
title: Класс RedisDB
excerpt: PHP фреймворк Neuron - класс RedisDB
---

Является дочерним классом от Redis.

Получить уже готовый экземпляр класса с выполненным подключением к БД можно с помощью метода `App::redis()`. Кроме этого, можно воспользоваться методом `App::redisCallback()` результат которого можно передать в виде callback функции. Это может быть полезно, если есть вероятность, что соединение с базой данных не понадобится. Соединение с БД будет инициализировано только в случае вызова callback функции.

## RedisDB::searchKeys

```php
public RedisDB::searchKeys(
    string $search_key
): array
```

Производит поиск ключей по шаблону. Аналогично `KEYS *`, но работает с использованием `SCAN`.

## RedisDB::deleteKeys

```php
public RedisDB::deleteKeys(
    string $search_key
): array
```

Удаляет ключи из Redis по заданному шаблону.
