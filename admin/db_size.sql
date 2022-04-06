sp_helpdb;
go

--посмотреть занимаемое пространство базами по дискам
select SUBSTRING(physical_name,0,2), SUM(size * 8.0 / 1024) as [Size, Mb]
from sys.master_files
GROUP BY SUBSTRING(physical_name,0,2)

--общий размер всех баз данных:
select SUM(size * 8.0 / 1024) as [Size, Mb]
from sys.master_files

--размер текущей бд
select DB_Name(database_id) as [Database Name], SUM(size * 8.0 / 1024) as [Size, Mb]
from sys.master_files
WHERE database_id = DB_ID()
GROUP BY database_id
