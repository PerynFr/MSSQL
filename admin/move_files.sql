ALTER DATABASE database_name MODIFY FILE ( NAME = logical_name, FILENAME = 'new_path\os_file_name' );

ALTER DATABASE database_name SET OFFLINE;

ALTER DATABASE database_name SET OFFLINE WITH ROLLBACK IMMEDIATE;

--Переместите файл или файлы в новое расположение.

ALTER DATABASE database_name SET ONLINE;

SELECT name, physical_name AS CurrentLocation, state_desc  
FROM sys.master_files  
WHERE database_id = DB_ID();
