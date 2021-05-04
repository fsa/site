```bash
git config --global user.name "FSA"
git config --global user.email fsa@mail.com
```
Секция [core]
```bash
git config --global core.editor vim
git config --global core.pager 'less -RFX'
```
Алиасы
```
[alias]
  ci = commit
  br = branch
  co = checkout
  st = status --short
```

```
[url "ssh://172.17.22.3/~/git/"]
        insteadOf = fsaserv:
        pushInsteadOf = fsaserv:
```
Удалить локально заданное имя или секцию user в .git
```bash
git config unset user.name
git config --remove-section user
```
Конфиг git локальный и глобальный
```bash
git config --list
git config --list --global
```
Много всего
```bash
git help config
```
