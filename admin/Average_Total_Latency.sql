--SQL Server troubleshooting: Disk I/O problems
/*
Средняя общая задержка представляет общую задержку для файлов базы данных,  
и мы можем использовать следующую таблицу в качестве справочной информации  
для оценки производительности диска по сравнению с задержкой.
The Average Total Latency column represents the total latency about the database files, and we can use the following table as reference to evaluate the disk performance against latency. 
--------
Excellent 
<1 ms 
 
Very good 
<5 ms 
 
Good 
<5 – 10 ms 
 
Poor 
< 10 – 20 ms 
 
Bad 
< 20 – 100 ms 

Very Bad  
<100 ms -500 ms 
 
Awful 
> 500 ms 
*/

SELECT  DB_NAME(vfs.database_id) AS database_name ,physical_name AS [Physical Name],
        size_on_disk_bytes / 1024 / 1024. AS [Size of Disk] ,
        CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [Average Read latency] ,
        CAST(io_stall_write_ms/(1.0 + num_of_writes) AS NUMERIC(10,1)) AS [Average Write latency] ,
        CAST((io_stall_read_ms + io_stall_write_ms)
/(1.0 + num_of_reads + num_of_writes) 
AS NUMERIC(10,1)) AS [Average Total Latency],
        num_of_bytes_read / NULLIF(num_of_reads, 0) AS    [Average Bytes Per Read],
        num_of_bytes_written / NULLIF(num_of_writes, 0) AS   [Average Bytes Per Write]
FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
  JOIN sys.master_files AS mf 
    ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
ORDER BY [Average Total Latency] DESC
