/************************************************************
   * Разделение резервной копии базы данных dbName, база данных относительно велика, для облегчения резервного копирования каждый файл резервной копии разбит на несколько файлов bak.
 * Time:  
 ************************************************************/
 
 USE [master]
 
 
 ------ Удалить старые данные ----------------------------------------- --------------------
--1. xp_delete_file  
 - Преимущества: хорошая совместимость  
 Недостатки: вы не можете удалять файлы, созданные вне SQL Server, включая RAR.  
 - Примечания: «Чистое обслуживание» в плане обслуживания также вызывает эту расширенную хранимую процедуру для удаления файлов.  
DECLARE @oldDate DATETIME  
SET @oldDate = GETDATE() -0  
--EXECUTE MASTER.dbo.xp_delete_file 
 -0, --0: файлы резервных копий, 1: текстовый отчет о плане обслуживания  
 -N'D: \ DataBak \ dbName \ ', - Путь к файлу  
 -N'bak ', -File расширение  
 - @ oldDate, - Все файлы до этого времени будут удалены  
 -1-Удалить файлы в подпапках  
 
 
EXEC xp_cmdshell 'rd D:\DataBak\dbName',
           no_output-удалить папку, чтобы очистить старую резервную копию 
EXEC xp_cmdshell 'mkdir D:\DataBak\dbName',
           no_output-воссоздать папку 
 
DECLARE @BakCount INT 
DECLARE @n INT 
DECLARE @Sql NVARCHAR(MAX) 
DECLARE @FILENAME VARCHAR(500)
DECLARE @DATABaseName VARCHAR(500)
DECLARE @DATABakPath VARCHAR(500)
 
SET @DATABakPath = 'D:\DataBak\'
 SET @BakCount = 5-Количество баз данных для разделения
SET @DATABaseName = 'dbName'
SET @n = 1
SET @FILENAME = REPLACE(
        REPLACE(
            REPLACE(CONVERT(VARCHAR, GETDATE(), 120), '-', ''),
            ' ',
            ''
        ),
        ':',
        ''
    ) + '';
DECLARE @exeText VARCHAR(100)
 SET @exeText = 'mkdir' + + @DATABakPath + @DATABaseName + '\' + @ FILENAME - создать резервную копию каталога 
EXEC xp_cmdshell @exeText,
     no_output    
SET @Sql = 'BACKUP DATABASE dbName 
TO DISK = N''' + @DATABakPath + @DATABaseName + '\' + @FILENAME + '\' + 
    @DATABaseName + '_' + @FILENAME + '_0.bak'''
WHILE @n < @BakCount
BEGIN
    SET @Sql = @Sql + ',
	DISK = N''' + @DATABakPath + @DATABaseName + '\' + @FILENAME + '\' + 
        @DATABaseName + '_' + @FILENAME + '_' + CONVERT(VARCHAR, @n) + '.bak'''
    
    SET @n = @n + 1
END
EXEC (@Sql) 
 
 
 ПЕЧАТЬ '----------- Резервное копирование' + @DATABaseName + 'Готово ---------------------' + CONVERT (VARCHAR (100) , GETDATE (), 126)
+ '---------------'




 
/ *** Восстановить разделенный файл резервной копии. Если файлов больше, вы можете обратиться к коду резервной копии. Циркулярная обработка ***** /
 
RESTORE DATABASE dbName FROM 
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_0.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_1.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_2.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_3.bak',
DISK = 'E:\DataBak\dbName\20181101201523\dbName_20181101201523_4.bak' 
WITH MOVE 'dbName' TO 'D:\SqlDataBase\dbName.mdf', 
     MOVE 'dbName_log' 
     TO 'D:\SqlDataBase\dbName_log.ldf',
     STATS = 5