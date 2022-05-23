CREATE TABLE #temp ( LogDate datetime, ProcessInfo varchar(100), TextData varchar(max) )

INSERT INTO #temp(LogDate, ProcessInfo, TextData)
EXEC sp_readerrorlog 0, 1, N'Manufacturer'

SELECT TextData FROM #temp


The root cause is that connection to SQL Server was temporary lost, for instance because of a network glitch. When the client regains contact, it attempts to recover the connection, but this is only possible under some conditions, and when it is not, you get this error message.

Host github.com
User git
Hostname ssh.github.com
PreferredAuthentications publickey
IdentityFile ~/.ssh/id_rsa
Port 443

Host gitlab.com
Hostname altssh.gitlab.com
User git
Port 443
PreferredAuthentications publickey
IdentityFile ~/.ssh/id_rsa

проверяем что 22 не заблокирован  
telnet example.com 22  
  
Ошибка: ssh: connect to host github.com port 22: Connection timed out  

ssh -v git@github.com -p 443
  
устранение:

(прежде всего убедитесь, что вы создали свои ключи, как описано на http://help.github.com/win-set-up-git/)

создать папка./~ ssh / config (файл конфигурации ssh, расположенный в вашем каталоге пользователя. На windows наверное %USERPROFILE%\.ssh\config

вставьте в него следующий код:

    Host github.com
    User git
    Hostname ssh.github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_rsa
    Port 443
  
  https://codengineering.ru/q/git-ssh-error-connect-to-host-bad-file-number-21033
