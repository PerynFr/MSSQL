@ off

REM Установите значения для переменных окружения, соответствующие вашей конфигурации
set "serverfile=servers.txt"  REM Имя файла, содержащего список серверов
set "username=your_username"  REM Имя пользователя SQL Server
set "password=your_password"  REM Пароль SQL Server
set "outputfile=jobmonitoring.txt"  REM Имя файла для сохранения результатов
set "emailrecipient=recipient@example.com"  REM Адрес электронной почты получателя
set "emailsubject=Job Monitoring Report"  REM Тема электронного письма

REM Очистка файла вывода
echo. > %outputfile%

REM Перебор серверов из файла
for /F "usebackq delims=" %%s in (%serverfile%) do (
    echo Подключение к серверу: %%s
    echo Подключение к серверу: %%s >>
    echo Подключение к серверу: %%s >> %outputfile%

    REM Получение списка заданий
    sqlcmd -S %%s -U %username% -P %password% -Q "SELECT name, current_execution_status FROM msdb.dbo.sysjobs" -o temp_output.txt

    REM Добавление результатов в файл вывода
    type temp_output.txt >> %outputfile%

    REM Удаление временного файла
    del temp_output.txt
)

REM Отправка результатов по электронной почте
powershell -ExecutionPolicy Bypass -Command "Send-MailMessage -From 'sender@example.com' -To '%emailrecipient%' -Subject '%emailsubject%' -Body 'Please find attached the job monitoring report' -Attachments '%outputfile%' -SmtpServer 'smtp.example.com'"

REM Удаление файла вывода
del %outputfile%
