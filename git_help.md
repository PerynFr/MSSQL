Работа с git  
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
  
  
git config --global --bool pull.rebase true  
#делаем pull автоматом на последние изменения в удаленном репозитории
  
  
