DECLARE @t TABLE (file_id int, DatabaseName varchar(100),
                                            Logical_Name varchar(100),
                                                         TYPE varchar(10),
                                                              FileSizeinMb numeric(10, 2),
                                                                           SpaceUsedinMb numeric(10, 2),
                                                                                         FreeSpaceinMB numeric(10, 2),
                                                                                                       [%ofFreeSpace] numeric(10, 2),
                                                                                                                      FileName varchar(200))
INSERT INTO @t EXEC sp_MSforeachdb 'use [?] 
select file_id as FileId,Db_name(database_id) as DatabaseName, name as Logical_Name, type_desc as Type, size*8/1024.0 as FileSizeinMb,
       convert(decimal(12,2),round(fileproperty([name],''SpaceUsed'')/128.000,2)) as SpaceUsedinMb,
       convert(decimal(12,2),round(([size]-fileproperty([name],''SpaceUsed''))/128.000,2)) as FreeSpaceinMB,
       cast((([size]-fileproperty([name],''SpaceUsed''))/128.00000)/([size]/128.000) as numeric(10,2))*100 as [%ofFreeSpace],
       RTRIM(LTRIM([physical_name])) AS FileName
       from sys.master_files
       where database_id = db_ID()'
---------------
SELECT b.Server,
       b.Disk,
       a.[File Size all DBs (MB)],
       a.[Used Data ALL DBs (MB)],
       a.[Free Space ALL DBs (MB)],
       b.[Total Disk Size in (MB)],
       b.[Disk Free %]
FROM
  (SELECT left(FileName, 1) Disk,
          sum(FileSizeinMb) [File Size all DBs (MB)],
          sum(SpaceUsedinMb) [Used Data ALL DBs (MB)],
          sum(FreeSpaceinMB) [Free Space ALL DBs (MB)]
   FROM @t
   GROUP BY left(FileName, 1) --having left(FileName,1)= 'G'
) a
JOIN
  (SELECT DISTINCT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,
                   volume_mount_point [Disk],
                   file_system_type [File System],
                   logical_volume_name AS [Logical Drive Name],
                   CONVERT(DECIMAL(18, 2), total_bytes/1048576.0) AS [Total Disk Size in (MB)], ---1GB = 1073741824 bytes CONVERT(DECIMAL(18,2),available_bytes/1073741824.0) AS [Available Size in GB],
CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT) AS DECIMAL(18, 2)) * 100 AS [Disk Free %]
   FROM sys.master_files CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)) b ON a.Disk=left(b.Disk, 1)
---------------
SELECT  file_id,
       DatabaseName,
       Logical_Name,
       TYPE,
       replace(FileSizeinMb, '.', ',') [File Size in (MB)],
       replace(SpaceUsedinMb, '.', ',') [Space DBs Used in (MB)],
       replace(FreeSpaceinMB, '.', ',') [Free Space DBs in (MB)],
       replace([%ofFreeSpace], '.', ',') [% of Free Space],
       FileName
FROM @t 
--where left(FileName,1)= 'd' --or in ('Custody_UAT_02', 'Custody_UAT_03', 'Export_UAT_02', 'Export_UAT_03')
ORDER BY FreeSpaceinMB DESC

-----------------
