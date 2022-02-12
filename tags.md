---
layout: default
---
# Заметки по ключевым словам

{% capture tags %}{% for tag in site.tags %}{{ tag[0] }},{% endfor %}{% endcapture %}
{% assign sortedtags = tags | split:',' | sort %}

{% for tag in sortedtags %}
  <h3 id="{{ tag }}">{{ tag }}</h3>
  <ul>
  {% for post in site.tags[tag] %}
    <li><a href="{{ post.url }}">{{ post.title }}</a> ({{ post.date| date: "%d.%m.%Y" }})</li>
  {% endfor %}
  </ul>
{% endfor %}
