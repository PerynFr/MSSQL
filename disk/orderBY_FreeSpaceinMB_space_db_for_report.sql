/* только селекты, просто нажми F5, @sqlmaster 20220715
скрипт формирует 3 датасета
1й - обшая информация сгрупированная по дискам для быстрого принятия решения
2й - для вставки в эсель и отправки пользователю, в нем заменены точки на запятые и эксель отформатирован чтобы пользователь мог суммировать колонки
	 сортировка по [Free Space DBs (GB)]
3й - удобный формат для отправки пользователю по сводной информации ни диске/дисках
	 чтобы не тратить время делая скриншоты, информация по дискам отделена пустой строкой для удобства копирования
	 если в письме текст отформатировать в формате синей подписи то сдвиги будут на одном уровне
*/
SET NOCOUNT ON;
DECLARE @t TABLE (file_id int,
				  DatabaseName varchar(100),
				  Logical_Name varchar(100),
				  TYPE varchar(10),
				  FileSizeinMb numeric(10, 2),
				  SpaceUsedinMb numeric(10, 2),
				  FreeSpaceinMB decimal(12, 2),
				  [%ofFreeSpace] decimal(10, 2),
				  FileName varchar(200))
INSERT INTO @t
EXEC sp_MSforeachdb 'use [?] 
select file_id as FileId,Db_name() as DatabaseName, name as Logical_Name, type_desc as Type, size/128.0 as FileSizeinMb,
       convert(decimal(12,2),round(fileproperty([name],''SpaceUsed'')/128.000,2)) as SpaceUsedinMb,
       convert(decimal(12,2),round((size/128.0)-(fileproperty([name],''SpaceUsed''))/128.000,2)) as FreeSpaceinMB,
       cast((([size]-fileproperty([name],''SpaceUsed''))/128.0000)/([size]/128.0000)*100.0000 as decimal(10,2)) as [%ofFreeSpace],
       RTRIM(LTRIM([physical_name])) AS FileName
       from sys.database_files(nolock)'
SELECT b.Server,
	   b.Disk,
	   a.[File Size DBs (GB)],
	   a.[Used Data DBs (GB)],
	   a.[Free Space all DBs (GB)],
	   b.[Total Disk Size (GB)],
	   b.[Available Size (GB)],
	   b.[Disk Free %],
	   CURRENT_TIMESTAMP [Space Timestamp]
FROM
  (SELECT left(FileName, 1) Disk,
		  cast(sum(FileSizeinMb)/1024 as numeric(10,2)) [File Size DBs (GB)],
		  cast(sum(SpaceUsedinMb)/1024 as numeric(10,2)) [Used Data DBs (GB)],
		  cast(sum(FreeSpaceinMB)/1024 as numeric(10,2)) [Free Space all DBs (GB)]
  FROM @t
  GROUP BY left(FileName, 1) 
--having left(FileName,1)= 'G'
) a
  JOIN
  (SELECT DISTINCT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,
  		  volume_mount_point [Disk],
		  file_system_type [File System],
		  logical_volume_name AS [Logical Drive Name],
		  CONVERT(DECIMAL(18, 2), total_bytes/1073741824.0) AS [Total Disk Size (GB)], ---1GB = 1073741824 bytes 
		  CONVERT(DECIMAL(18,2),available_bytes/1073741824.0) AS [Available Size (GB)],
		  CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT)* 100 AS DECIMAL(18, 2))  AS [Disk Free %]
  FROM sys.master_files(nolock) CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)) b ON a.Disk=left(b.Disk, 1)
order by b.[Disk Free %]
---------------
SELECT file_id,
	   DatabaseName,
	   Logical_Name,
	   TYPE,
	   replace(FileSizeinMb, '.', ',') [File Size in (MB)],
	   replace(SpaceUsedinMb, '.', ',') [Space DBs Used in (MB)],
	   replace(FreeSpaceinMB, '.', ',') [Free Space all DBs in (MB)],
	   replace([%ofFreeSpace], '.', ',') [% of Free Space],
	   FileName
FROM @t
--where DatabaseName not in ('tempdb', 'msdb', 'model', 'master')
--and left(FileName,1)= 'd' --or in ('Custody_UAT_02', 'Custody_UAT_03', 'Export_UAT_02', 'Export_UAT_03')
--where left(FileName,1)= 'e' --DatabaseName  in ('AVC_UAT_PIF_13')
ORDER BY FreeSpaceinMB DESC
/*
отчет по общему и свободному месту на диске + tempdb отдельной строкой
для отправки по почте
*/
SELECT har = CASE
                 WHEN har = 'Server' THEN har + replicate('.', 58 - DATALENGTH(value))
                 WHEN har = 'Disk' THEN har +' ....................................'
                 WHEN har = 'File Size DBs (GB)' THEN har +'  ..............'
                 WHEN har = 'Free Space all DBs (GB)' THEN har +'  ........'
                 WHEN har = 'Total Disk Size (GB)' THEN har +'  ............'
                 WHEN har = 'Available Size (GB)' THEN har +'  ............'
				 WHEN har = 'Used Data tempdb (GB)' THEN har +'  ......'
                 WHEN har = 'Used Data all DBs (GB)' THEN har +'  ........'
                 WHEN har = 'Disk Free %' THEN har +' .......................'
                 WHEN har = 'Space Timestamp' THEN har +' .............'
                 ELSE har
             END,
             value
FROM
  (SELECT b.[Server],
          cast(b.[Disk] AS VARCHAR(255)) [Disk],
          cast(a.[File Size DBs (GB)] AS VARCHAR(255)) [File Size DBs (GB)],
          cast(a.[Used Data DBs (GB)] AS VARCHAR(255)) [Used Data all DBs (GB)],
		  cast(c.[Used Data tempdb (GB)] AS VARCHAR(255)) [Used Data tempdb (GB)],
          cast(a.[Free Space all DBs (GB)] AS VARCHAR(255)) [Free Space all DBs (GB)],
          cast(b.[Total Disk Size (GB)] AS VARCHAR(255)) [Total Disk Size (GB)],
          cast(b.[Available Size (GB)] AS VARCHAR(255)) [Available Size (GB)],
          cast(b.[Disk Free %] AS VARCHAR(255)) [Disk Free %],
          convert(VARCHAR(255), CURRENT_TIMESTAMP, 121) [Space Timestamp],
          cast('' AS VARCHAR(255)) [ ]
   FROM
     (SELECT left(FileName, 1) Disk,
             cast(sum(FileSizeinMb)/1024 AS numeric(10, 2)) [File Size DBs (GB)],
             cast(sum(SpaceUsedinMb)/1024 AS numeric(10, 2)) [Used Data DBs (GB)],
             cast(sum(FreeSpaceinMB)/1024 AS numeric(10, 2)) [Free Space all DBs (GB)]
      FROM @t
      GROUP BY left(FileName, 1) --HAVING left(FileName, 1)= 'f'
 ) a
   JOIN
     (SELECT DISTINCT CONVERT(VARCHAR(255), SERVERPROPERTY('Servername')) AS Server,
                      cast(volume_mount_point AS VARCHAR(255)) [Disk],
                      file_system_type [File System],
                      logical_volume_name AS [Logical Drive Name],
                      CONVERT(DECIMAL(18, 2), total_bytes/1073741824.0) AS [Total Disk Size (GB)], ---1GB = 1073741824 bytes
					  CONVERT(DECIMAL(18, 2), available_bytes/1073741824.0) AS [Available Size (GB)],
					  CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT)*100.00 AS DECIMAL(18, 2)) AS [Disk Free %]
      FROM sys.master_files(nolock) CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)
 ) b 
   ON a.Disk=left(b.Disk, 1)
   left join
 (
   	 SELECT left(FileName, 1) Disk,
			cast(sum(FileSizeinMb)/1024 AS numeric(10, 2)) [Used Data tempdb (GB)]
	 FROM @t where DatabaseName = 'tempdb'
	 GROUP BY left(FileName, 1)
 ) c 
 ON a.Disk=left(c.Disk, 1)
 ) p unpivot (value
                    FOR har in ([Server], 
								[Disk], 
								[File Size DBs (GB)], 
								[Used Data all DBs (GB)],
								[Used Data TempDB (GB)],
								[Free Space all DBs (GB)], 
								[Total Disk Size (GB)], 
								[Available Size (GB)], 
								[Disk Free %], 
								[Space Timestamp], 
								[ ])) AS upvt