# Работа с git  
## Основы Git - Создание Git-репозитория  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-Git-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F  
  
# Псевдонимы в Git  
git config --global alias.co checkout  
git config --global alias.br branch  
git config --global alias.ci commit  
git config --global alias.st status  
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
  
## для исключения из индекса  
git reset HEAD CONTRIBUTING.md  
  
## Отмена изменений в файле  
git checkout -- CONTRIBUTING.md  

## удаляем изменения из рабочей дирректории  
git restore db.db  
## Файл CONTRIBUTING.md изменен, но снова не индексирован.  
git restore --staged CONTRIBUTING.md  
  
## git rm, удаляет файл из вашего рабочего каталога  
## Если вы изменили файл и уже проиндексировали его, вы должны использовать принудительное удаление с помощью параметра -f  
git rm temp.md -f  

## отслеживание изменений  
если вы хотите увидеть сокращенную статистику для каждого коммита, вы можете использовать опцию --stat:  
git log --stat  
-p или --patch, который показывает разницу (выводит патч), внесенную в каждый коммит. Так же вы можете ограничить количество   
записей в выводе команды; используйте параметр -2 для вывода только двух записей  
git log -p -2  
-p  
Показывает патч для каждого коммита.  
--stat  
Показывает статистику измененных файлов для каждого коммита.  
--shortstat  
Отображает только строку с количеством изменений/вставок/удалений для команды --stat.  
--name-only  
Показывает список измененных файлов после информации о коммите.  
--name-status  
Показывает список файлов, которые добавлены/изменены/удалены.  
--abbrev-commit  
Показывает только несколько символов SHA-1 чек-суммы вместо всех 40.  
--relative-date  
Отображает дату в относительном формате (например, «2 weeks ago») вместо стандартного формата даты.  
--graph  
Отображает ASCII граф с ветвлениями и историей слияний.  
--pretty  
Показывает коммиты в альтернативном формате. Возможные варианты опций: oneline, short, full, fuller и format (с помощью последней   
можно указать свой формат).  
--oneline  
Сокращение для одновременного использования опций   
--pretty=oneline --abbrev-commit.  

## Problem with win1251 encoding  
I just added into file .git/config this lines:  
  
[gui]  
        encoding = cp1251  


## перемещение дирректории git mv a folder and sub folders in windows   
function Move-GitFolder {
    param (
        $target,
        $destination
    )
    
    Get-ChildItem $target -recurse |
    Where-Object { ! $_.PSIsContainer } |
    ForEach-Object { 
        $fullTargetFolder = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $target))
        $fullDestinationFolder = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $destination))
        $fileDestination = $_.Directory.FullName.Replace($fullTargetFolder.TrimEnd('\'), $fullDestinationFolder.TrimEnd('\'))

        New-Item -ItemType Directory -Force -Path $fileDestination | Out-Null

        $filePath = Join-Path $fileDestination $_.Name

        git mv $_.FullName $filePath
        
    }
}  

Применение  
  
Move-GitFolder <Target folder> <Destination folder>
  
Преимущество этого решения по сравнению с другими решениями заключается в том, что оно рекурсивно перемещает папки и файлы и даже   создает структуру папок, если она не существует.  
  
способ 2  
Убедитесь, что правильный путь выбран в консоли git при выполнении команды:  

- git mv Source Destination  
При необходимости используйте:  

- cd SourceFolder  
А затем команда mv.  

## Псевдонимы в Git   https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%81%D0%B5%D0%B2%D0%B4%D0%BE%D0%BD%D0%B8%D0%BC%D1%8B-%D0%B2-Git#r_git_aliases  
git config --global alias.c commit  
git config --global alias.s status  
git config --global alias.l 'log -1 HEAD'  
