# Работа с git  
## Основы Git - Создание Git-репозитория  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-Git-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F  
  
# Псевдонимы в Git  
$ git config --global alias.co checkout  
$ git config --global alias.br branch  
$ git config --global alias.ci commit  
$ git config --global alias.st status  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%81%D0%B5%D0%B2%D0%B4%D0%BE%D0%BD%D0%B8%D0%BC%D1%8B-%D0%B2-Git#r_git_aliases  


## просмотреть все настройки  
git config --list --show-origin  
  
## Имя пользователя  
git config --global user.name "PerynFr"  
git config --global user.email johndoe@example.com  

настраиваем notepad вместо Vim  
https://stackoverflow.com/questions/13340329/how-to-save-a-git-commit-message-from-windows-cmd  

Расширение дерево для google chrome для работы с GIT   
Octotree - GitHub code tree  

Просмотр-истории-коммитов  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%80%D0%BE%D1%81%D0%BC%D0%BE%D1%82%D1%80-%D0%B8%D1%81%D1%82%D0%BE%D1%80%D0%B8%D0%B8-%D0%BA%D0%BE%D0%BC%D0%BC%D0%B8%D1%82%D0%BE%D0%B2  
  
Origin - это наш репозиторий и main - это ремоут ветка. Если мы всегда так будет писать, то оно будет работать.   
Естественно каждый раз это писать лень, поэтому есть второй вариант.  
Второй вариант это указать трекинг информацию для этой ветки и тогда мы всегда будем пулить правильную ветку.  

git branch --set-upstream-to=origin/main  
https://monsterlessons.com/project/lessons/git-izuchaem-komandy-pull-i-push
  
## делаем pull автоматом на последние изменения в удаленном репозитории
git config --global --bool pull.rebase true  
  
## настраиваем merge утилиту  
git config --global merge.tool smerge  
git config --global mergetool.smerge.path "c:\Program Files\Sublime Merge\sublime_merge.exe"
  
## изменить URL удаленного репозитория  
git remote -v   просмотреть текущий URL  
git remote set-url origin https://notabug.org/Peryn/temp.git  
Второй способ:  
Отредактировать файл .git/config: секция [remote "origin"] параметр - url.  

## дать права на дирректорию проекта git текущему пользователю если ошибка  
error: cannot open .git/FETCH_HEAD: Permission denied  
sudo chown -R $USER: .

## удаляем изменения из рабочей дирректории  
git restore db.db
