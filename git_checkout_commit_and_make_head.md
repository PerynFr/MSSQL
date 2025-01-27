git reflog

# смотрим все ли там
git checkout 5ea1e78
## можно создать новую ветку
git checkout -b новая-ветка 5ea1e78

## если все там возвращам мастер
git checkout master
git reset --hard 5ea1e78
git push --force origin master

## проверяем 
git branch
git log --oneline
