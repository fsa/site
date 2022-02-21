---
layout: default
excerpt: Мой блог
---
# Заметки

[Заметки по ключевым словам](/tags)

{% for post in site.posts %}
{{ post.date| date: "%d.%m.%Y" }}&nbsp;&mdash;&nbsp;[{{ post.title }}]({{ post.url }})

{% endfor %}
