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
```basg
git config --global alias.ci commit
git config --global alias.br branch
git config --global alias.co checkout
git config --global alias.st "status --short"
git config --global alias.hist "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
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
