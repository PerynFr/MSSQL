sp_helpdb;
go
sp_helplog
go
--свободное место на дисках
xp_fixeddrives 

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

--размер файлов с путями
SELECT  @@Servername AS Server ,
        DB_NAME() AS DB_Name ,
        File_id ,
        Type_desc ,
        Name ,
        LEFT(Physical_Name, 1) AS Drive ,
        Physical_Name ,
        RIGHT(physical_name, 3) AS Ext ,
        cast(Size/128 as nvarchar(10))  + ' mb' ,
        Growth
FROM    sys.database_files
ORDER BY File_id; 
go
