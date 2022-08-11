# ������ � git  
## ������ Git - �������� Git-�����������  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%A1%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-Git-%D1%80%D0%B5%D0%BF%D0%BE%D0%B7%D0%B8%D1%82%D0%BE%D1%80%D0%B8%D1%8F  
  
# ���������� � Git  
git config --global alias.co checkout  
git config --global alias.br branch  
git config --global alias.ci commit  
git config --global alias.st status  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%81%D0%B5%D0%B2%D0%B4%D0%BE%D0%BD%D0%B8%D0%BC%D1%8B-%D0%B2-Git#r_git_aliases  


## ����������� ��� ���������  
git config --list --show-origin  
  
## ��� ������������  
git config --global user.name "PerynFr"  
git config --global user.email johndoe@example.com  

����������� notepad ������ Vim  
https://stackoverflow.com/questions/13340329/how-to-save-a-git-commit-message-from-windows-cmd  

���������� ������ ��� google chrome ��� ������ � GIT   
Octotree - GitHub code tree  

��������-�������-��������  
https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%80%D0%BE%D1%81%D0%BC%D0%BE%D1%82%D1%80-%D0%B8%D1%81%D1%82%D0%BE%D1%80%D0%B8%D0%B8-%D0%BA%D0%BE%D0%BC%D0%BC%D0%B8%D1%82%D0%BE%D0%B2  
  
Origin - ��� ��� ����������� � main - ��� ������ �����. ���� �� ������ ��� ����� ������, �� ��� ����� ��������.   
����������� ������ ��� ��� ������ ����, ������� ���� ������ �������.  
������ ������� ��� ������� ������� ���������� ��� ���� ����� � ����� �� ������ ����� ������ ���������� �����.  

git branch --set-upstream-to=origin/main  
https://monsterlessons.com/project/lessons/git-izuchaem-komandy-pull-i-push
  
## ������ pull ��������� �� ��������� ��������� � ��������� �����������
git config --global --bool pull.rebase true  
  
## ����������� merge �������  
git config --global merge.tool smerge  
git config --global mergetool.smerge.path "c:\Program Files\Sublime Merge\sublime_merge.exe"
  
## �������� URL ���������� �����������  
git remote -v   ����������� ������� URL  
git remote set-url origin https://notabug.org/Peryn/temp.git  
������ ������:  
��������������� ���� .git/config: ������ [remote "origin"] �������� - url.  

## ���� ����� �� ����������� ������� git �������� ������������ ���� ������  
error: cannot open .git/FETCH_HEAD: Permission denied  
sudo chown -R $USER: .  
  
## ��� ���������� �� �������  
git reset HEAD CONTRIBUTING.md  
  
## ������ ��������� � �����  
git checkout -- CONTRIBUTING.md  

## ������� ��������� �� ������� �����������  
git restore db.db  
## ���� CONTRIBUTING.md �������, �� ����� �� ������������.  
git restore --staged CONTRIBUTING.md  
  
## git rm, ������� ���� �� ������ �������� ��������  
## ���� �� �������� ���� � ��� ���������������� ���, �� ������ ������������ �������������� �������� � ������� ��������� -f  
git rm temp.md -f  

## ������������ ���������  
���� �� ������ ������� ����������� ���������� ��� ������� �������, �� ������ ������������ ����� --stat:  
git log --stat  
-p ��� --patch, ������� ���������� ������� (������� ����), ��������� � ������ ������. ��� �� �� ������ ���������� ����������   
������� � ������ �������; ����������� �������� -2 ��� ������ ������ ���� �������  
git log -p -2  
-p  
���������� ���� ��� ������� �������.  
--stat  
���������� ���������� ���������� ������ ��� ������� �������.  
--shortstat  
���������� ������ ������ � ����������� ���������/�������/�������� ��� ������� --stat.  
--name-only  
���������� ������ ���������� ������ ����� ���������� � �������.  
--name-status  
���������� ������ ������, ������� ���������/��������/�������.  
--abbrev-commit  
���������� ������ ��������� �������� SHA-1 ���-����� ������ ���� 40.  
--relative-date  
���������� ���� � ������������� ������� (��������, �2 weeks ago�) ������ ������������ ������� ����.  
--graph  
���������� ASCII ���� � ����������� � �������� �������.  
--pretty  
���������� ������� � �������������� �������. ��������� �������� �����: oneline, short, full, fuller � format (� ������� ���������   
����� ������� ���� ������).  
--oneline  
���������� ��� �������������� ������������� �����   
--pretty=oneline --abbrev-commit.  

## Problem with win1251 encoding  
I just added into file .git/config this lines:  
  
[gui]  
        encoding = cp1251  


## ����������� ����������� git mv a folder and sub folders in windows   
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

����������  
  
Move-GitFolder <Target folder> <Destination folder>
  
������������ ����� ������� �� ��������� � ������� ��������� ����������� � ���, ��� ��� ���������� ���������� ����� � ����� � ����   ������� ��������� �����, ���� ��� �� ����������.  
  
������ 2  
���������, ��� ���������� ���� ������ � ������� git ��� ���������� �������:  

- git mv Source Destination  
��� ������������� �����������:  

- cd SourceFolder  
� ����� ������� mv.  

## ���������� � Git   https://git-scm.com/book/ru/v2/%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B-Git-%D0%9F%D1%81%D0%B5%D0%B2%D0%B4%D0%BE%D0%BD%D0%B8%D0%BC%D1%8B-%D0%B2-Git#r_git_aliases  
git config --global alias.c commit  
git config --global alias.s status  
git config --global alias.l 'log -1 HEAD'  
