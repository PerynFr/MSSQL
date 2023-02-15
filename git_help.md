# Работа с git  
## Основы Git - Создание Git-репозитория  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-Git-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F  
  
# Псевдонимы в Git
```  
git config --global alias.co checkout  
git config --global alias.br branch  
git config --global alias.c commit  
git config --global alias.s status  
```
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%81%D0%B5%D0%B2%D0%B4%D0%BE%D0%BD%D0%B8%D0%BC%D1%8B-%D0%B2-Git#r_git_aliases  


## просмотреть все настройки  
```
git config --list --show-origin  
```
  
## Имя пользователя  
```
git config --global user.name "PerynFr"  
git config --global user.email johndoe@example.com  
```
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
# Рекомендуется настроить Git на merges 
git config --local pull.rebase merges
git config --global pull.rebase merges  
  
## настраиваем merge утилиту  
git config --global merge.tool smerge  
git config --global mergetool.smerge.path "c:\Program Files\Sublime Merge\smerge.exe"

## Редактор
git config --global core.editor "'c:\Program Files\Sublime Text\sublime_text.exe' -w"
  
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

##  Отменить локальные изменения
git reset --hard
  
## Отмена изменений в файле  
git checkout -- CONTRIBUTING.md  

## Если необходимо вернуть файл до предыдущего состояни определенного коммита
необходимо в git log найти хэш ребуемого коммита и прописать git checkout commit_hash path_to_file, где commit_hash - хэш необходимого коммита и path_to_file - путь до файла, который необходимо скинуть.
Пример: Я добавил в коммит и отправил в удаленную ветку ненужный файл. Поэтому командой git log нашел хэш предпоследнего коммита и выполнил команду: git checkout db449e5882a85636ae9444c24ec78fe135312ee3 widgets/assets/js/main.min.js
После чего снова запушил файл git add widgets/assets/js/main.min.js -> git commit -m 'fix min.js' -> git push origin CORE-2093. В репозитории в ПР файл откатился до начального состояния.

## удаляем изменения из рабочей дирректории  
git restore db.db  
## Файл CONTRIBUTING.md изменен, но снова не индексирован.  
git restore --staged CONTRIBUTING.md  
  
## git rm, удаляет файл из вашего рабочего каталога  
## Если вы изменили файл и уже проиндексировали его, вы должны использовать принудительное удаление с помощью параметра -f  
git rm temp.md -f  
git rm "SQL decommissioning" -r  # удаляем католог рекурсивно  

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

## решаем проблему с merge
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   catalogs/price_dsv_mebel.xlsx
        modified:   db.db
        modified:   readme.txt
        modified:   run as systenctl.txt
        new file:   start.cmd

Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
        both modified:   .env


c:\Repository\PycharmProjects\vyrok_bot>git merge
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
error: Merging is not possible because you have unmerged files.
hint: Fix them up in the work tree, and then use 'git add/rm <file>'
hint: as appropriate to mark resolution and make a commit.
fatal: Exiting because of an unresolved conflict.

c:\Repository\PycharmProjects\vyrok_bot>git s
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
interactive rebase in progress; onto f11cc8b
Last command done (1 command done):
   pick b769b91 start.cmd
No commands remaining.
You are currently rebasing branch 'master' on 'f11cc8b'.
  (fix conflicts and then run "git rebase --continue")
  (use "git rebase --skip" to skip this patch)
  (use "git rebase --abort" to check out the original branch)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   catalogs/price_dsv_mebel.xlsx
        modified:   db.db
        modified:   readme.txt
        modified:   run as systenctl.txt
        new file:   start.cmd

Unmerged paths:
  (use "git restore --staged <file>..." to unstage)
  (use "git add <file>..." to mark resolution)
        both modified:   .env

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   readme.txt


c:\Repository\PycharmProjects\vyrok_bot>git add .
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"

c:\Repository\PycharmProjects\vyrok_bot>git mergetool
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
No files need merging

c:\Repository\PycharmProjects\vyrok_bot>git pull
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
error: cannot pull with rebase: Your index contains uncommitted changes.
error: please commit or stash them.

c:\Repository\PycharmProjects\vyrok_bot>git add .
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"

c:\Repository\PycharmProjects\vyrok_bot>git s
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
interactive rebase in progress; onto f11cc8b
Last command done (1 command done):
   pick b769b91 start.cmd
No commands remaining.
You are currently rebasing branch 'master' on 'f11cc8b'.
  (all conflicts fixed: run "git rebase --continue")

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   .env
        modified:   catalogs/price_dsv_mebel.xlsx
        modified:   db.db
        modified:   readme.txt
        modified:   run as systenctl.txt
        new file:   start.cmd


c:\Repository\PycharmProjects\vyrok_bot>git c -m "start.cmd"
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
[detached HEAD 69bafdf] start.cmd
 6 files changed, 78 insertions(+), 30 deletions(-)
 create mode 100644 start.cmd

c:\Repository\PycharmProjects\vyrok_bot>git push
fatal: You are not currently on a branch.
To push the history leading to the current (detached HEAD)
state now, use

    git push origin HEAD:<name-of-remote-branch>


c:\Repository\PycharmProjects\vyrok_bot>git pull
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
You are not currently on a branch.
Please specify which branch you want to rebase against.
See git-pull(1) for details.

    git pull <remote> <branch>


c:\Repository\PycharmProjects\vyrok_bot>git push --force
fatal: You are not currently on a branch.
To push the history leading to the current (detached HEAD)
state now, use

    git push origin HEAD:<name-of-remote-branch>


c:\Repository\PycharmProjects\vyrok_bot>git push origin HEAD:master --force
Enumerating objects: 16, done.
Counting objects: 100% (16/16), done.
Delta compression using up to 2 threads
Compressing objects: 100% (8/8), done.
Writing objects: 100% (9/9), 121.50 KiB | 2.25 MiB/s, done.
Total 9 (delta 5), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (5/5), completed with 5 local objects.
To https://github.com/PerynFr/vyrok_bot.git
   f11cc8b..69bafdf  HEAD -> master

c:\Repository\PycharmProjects\vyrok_bot>git pull
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
You are not currently on a branch.
Please specify which branch you want to rebase against.
See git-pull(1) for details.

    git pull <remote> <branch>


c:\Repository\PycharmProjects\vyrok_bot>git s
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
interactive rebase in progress; onto f11cc8b
Last command done (1 command done):
   pick b769b91 start.cmd
No commands remaining.
You are currently editing a commit while rebasing branch 'master' on 'f11cc8b'.
  (use "git commit --amend" to amend the current commit)
  (use "git rebase --continue" once you are satisfied with your changes)

nothing to commit, working tree clean

c:\Repository\PycharmProjects\vyrok_bot>git rebase --continue
hint: core.useBuiltinFSMonitor=true is deprecated;please set core.fsmonitor=true instead
hint: Disable this message with "git config advice.useCoreFSMonitorConfig false"
Successfully rebased and updated refs/heads/master.

## работа с ветками (ветки, ветка)
https://monsterlessons.com/project/lessons/git-uchimsya-rabotat-s-pravilnym-workflow  
  
короткая форма записи, которая сразу создает ветку и переходит на нее  

git checkout -b develop 
git checkout develop # если ветка уже есть ее создавать ненадо

мы создали develop ветку и перешли на него. Давайте запушим ее в репозиторий  

git push  
  
переходим на мастер и мерджим develop в мастер  

git checkout master  

git merge develop  

git push  
https://webdevkin.ru/courses/git/git-merge  

# если не работает gitignore

Чтобы отменить отслеживание одного файла, который уже был добавлен/инициализирован в ваш репозиторий, т. е. остановить отслеживание файла, но не удалять его из вашей системы, используйте:  
git rm --cached filename  

для всех файлов  
Сначала зафиксируйте любые незавершенные изменения кода, а затем выполните эту команду:  
git rm -r --cached  
git add .  
git commit -m ".gitignore is now working"  

