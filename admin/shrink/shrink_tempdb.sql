/*
Если операция shrink не привела к уменьшению файла БД, значит необходимо произвести сброс буферов и кешей сервера и повторить shrink :
Создаем checkpoint и сбрасываем буферы страниц и индексов на диск:
*/
CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO

--Чистим кеш хранимых процедур:
DBCC FREEPROCCACHE;
GO

--Очищаем остальные типы кешей:
DBCC FREESYSTEMCACHE ('ALL');
GO

--Чистим кеш сессий:
DBCC FREESESSIONCACHE;
GO
--После этого можно повторно запустить сжатие файла — место на диске должно освободиться (способ чаще всего срабатывает и без первого пункта — без создания checkpoint и сброса буфера страниц).

USE [tempdb]
GO
DBCC SHRINKFILE (TEMPDEV, 1024)
GO

USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , EMPTYFILE)
GO


--Shrink All Tempdb Datafiles Script:

---Change the size in MB to shrink to---
DECLARE @size NVARCHAR(10) = 1024
----------------------------------------
DECLARE @info nvarchar(max)
DECLARE @file nvarchar(max)
DECLARE @q1 nvarchar(max)
DECLARE tempdb_cursor cursor for
SELECT NAME FROM sys.master_files WHERE database_id = 2 AND NAME !='templog';
OPEN tempdb_cursor
FETCH NEXT FROM tempdb_cursor into @info
while @@fetch_status = 0
BEGIN
SET @info = @info
SET @q1 = 'USE [tempdb] DBCC SHRINKFILE (''' + @info + ''' , ' + @size + ')'
--EXEC @Q1
PRINT @q1
FETCH NEXT FROM tempdb_cursor
INTO @info
END
CLOSE tempdb_cursor;
DEALLOCATE tempdb_cursor;
