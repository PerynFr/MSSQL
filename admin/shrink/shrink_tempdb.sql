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
