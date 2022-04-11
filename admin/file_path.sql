--Физическое расположение выбранной БД

EXEC sp_Helpfile; 

--OR 

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


-- имя и пути текущей базы
SELECT name, physical_name AS CurrentLocation, state_desc  
FROM sys.master_files  
WHERE database_id = DB_ID();
