USE [EES];
go
declare @i int = 10
WHILE @i > 0
begin
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
--Чистим кеш хранимых процедур:
DBCC FREEPROCCACHE;
--Очищаем остальные типы кешей:
DBCC FREESYSTEMCACHE ('ALL');
--Чистим кеш сессий:
DBCC FREESESSIONCACHE;
--После этого можно повторно запустить сжатие файла — место на диске должно освободиться (способ чаще всего срабатывает и без первого пункта — без создания checkpoint и сброса буфера страниц).
DBCC SHRINKFILE (N'EES_log' , EMPTYFILE);
print cast(@i as nchar(2))
set @i=@i-1
end;
