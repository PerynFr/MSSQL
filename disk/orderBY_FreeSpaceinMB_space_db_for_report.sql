DECLARE @t TABLE (file_id int,
  DatabaseName varchar(100),
  Logical_Name varchar(100),
  TYPE varchar(10),
  FileSizeinMb numeric(10, 2),
  SpaceUsedinMb numeric(10, 2),
  FreeSpaceinMB numeric(10, 2),
  [%ofFreeSpace] decimal(10, 2),
  FileName varchar(200))
INSERT INTO @t
EXEC sp_MSforeachdb 'use [?] 
select file_id as FileId,Db_name(database_id) as DatabaseName, name as Logical_Name, type_desc as Type, size*8/1024.0 as FileSizeinMb,
       convert(decimal(12,2),round(fileproperty([name],''SpaceUsed'')/128.000,2)) as SpaceUsedinMb,
       convert(decimal(12,2),round(([size]-fileproperty([name],''SpaceUsed''))/128.000,2)) as FreeSpaceinMB,
       cast((([size]-fileproperty([name],''SpaceUsed''))/128.0000)/([size]/128.0000)*100.0000 as decimal(10,2)) as [%ofFreeSpace],
       RTRIM(LTRIM([physical_name])) AS FileName
       from sys.master_files
       where database_id = db_ID()'
---------------
--select 'Server','Disk','File Size DBs (GB)','Used Data DBs (GB)','Free Space DBs (GB)','Total Disk Size (GB)','Available Size (GB)','Disk Free %','Space Timestamp'
--union all
SELECT b.Server,
  b.Disk,
  a.[File Size DBs (GB)],
  a.[Used Data DBs (GB)],
  a.[Free Space DBs (GB)],
  b.[Total Disk Size (GB)],
  b.[Available Size (GB)],
  b.[Disk Free %],
  CURRENT_TIMESTAMP [Space Timestamp]
FROM
  (SELECT left(FileName, 1) Disk,
    cast(sum(FileSizeinMb)/1024 as numeric(10,2)) [File Size DBs (GB)],
    cast(sum(SpaceUsedinMb)/1024 as numeric(10,2)) [Used Data DBs (GB)],
    cast(sum(FreeSpaceinMB)/1024 as numeric(10,2)) [Free Space DBs (GB)]
  FROM @t
  GROUP BY left(FileName, 1) --having left(FileName,1)= 'G'
) a
  JOIN
  (SELECT DISTINCT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,
    volume_mount_point [Disk],
    file_system_type [File System],
    logical_volume_name AS [Logical Drive Name],
    CONVERT(DECIMAL(18, 2), total_bytes/1073741824.0) AS [Total Disk Size (GB)], ---1GB = 1073741824 bytes 
    CONVERT(DECIMAL(18,2),available_bytes/1073741824.0) AS [Available Size (GB)],
    CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT)* 100 AS DECIMAL(18, 2))  AS [Disk Free %]
  FROM sys.master_files CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)) b ON a.Disk=left(b.Disk, 1)
order by b.[Disk Free %]
---------------
SELECT file_id,
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
--where DatabaseName  in ('AVC_UAT_PIF_13')
ORDER BY FreeSpaceinMB DESC


/*
отчет по общему и свободному месту на диске
для отправки по почте
*/
SELECT har = CASE
                 WHEN har = 'Server' THEN har +'  ....................................'
                 WHEN har = 'Disk' THEN har +'  ..............................'
				 WHEN har = 'File Size DBs (GB)' THEN har +'  ............'
				 WHEN har = 'Free Space DBs (GB)' THEN har +'  ............'
				 WHEN har = 'Total Disk Size (GB)' THEN har +'  ............'
				 WHEN har = 'Available Size (GB)' THEN har +'  ............'
				 WHEN har = 'Used Data DBs (GB)' THEN har +'  ............'
                 WHEN har = 'Disk Free %' THEN har +' ...................'
				 WHEN har = 'Space Timestamp' THEN har +' .............'
                 ELSE har
             END,
  value
FROM
  (SELECT b.[Server],
    cast(b.[Disk] AS VARCHAR(255)) [Disk],
    cast(a.[File Size DBs (GB)] AS VARCHAR(255)) [File Size DBs (GB)],
    cast(a.[Used Data DBs (GB)] AS VARCHAR(255)) [Used Data DBs (GB)],
    cast(a.[Free Space DBs (GB)] AS VARCHAR(255)) [Free Space DBs (GB)],
    cast(b.[Total Disk Size (GB)] AS VARCHAR(255)) [Total Disk Size (GB)],
    cast(b.[Available Size (GB)] AS VARCHAR(255)) [Available Size (GB)],
    cast(b.[Disk Free %] AS VARCHAR(255)) [Disk Free %],
    convert(VARCHAR(255), CURRENT_TIMESTAMP, 121) [Space Timestamp],
	 cast('' AS VARCHAR(255)) [ ]
  FROM
    (SELECT left(FileName, 1) Disk,
      cast(sum(FileSizeinMb)/1024 AS numeric(10, 2)) [File Size DBs (GB)],
      cast(sum(SpaceUsedinMb)/1024 AS numeric(10, 2)) [Used Data DBs (GB)],
      cast(sum(FreeSpaceinMB)/1024 AS numeric(10, 2)) [Free Space DBs (GB)]
    FROM @t
    GROUP BY left(FileName, 1)
    --HAVING left(FileName, 1)= 'f'
	) a
    JOIN
    (SELECT DISTINCT CONVERT(VARCHAR(255), SERVERPROPERTY('Servername')) AS Server,
      cast(volume_mount_point AS VARCHAR(255)) [Disk],
      file_system_type [File System],
      logical_volume_name AS [Logical Drive Name],
      CONVERT(DECIMAL(18, 2), total_bytes/1073741824.0) AS [Total Disk Size (GB)], ---1GB = 1073741824 bytes
      CONVERT(DECIMAL(18, 2), available_bytes/1073741824.0) AS [Available Size (GB)],
      CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT)*100.00 AS DECIMAL(18, 2)) AS [Disk Free %]
    FROM sys.master_files CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)) b ON a.Disk=left(b.Disk, 1)) p unpivot (value
             FOR har in ([Server], [Disk], [File Size DBs (GB)], [Used Data DBs (GB)], [Free Space DBs (GB)], [Total Disk Size (GB)], [Available Size (GB)], [Disk Free %], [Space Timestamp], [ ])) AS upvt
