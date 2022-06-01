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
SELECT sum(FileSizeinMb) FileSizeinMb_ALL, sum(SpaceUsedinMb) SpaceUsedinMb_ALL, sum(FreeSpaceinMB) FreeSpaceinMB_ALL
FROM @t
SELECT file_id,
       DatabaseName,
       Logical_Name,
       TYPE,
       replace(FileSizeinMb, '.', ',') FileSize_inMb,
       replace(SpaceUsedinMb, '.', ',') SpaceUsed_inMb,
       replace(FreeSpaceinMB, '.', ',') FreeSpace_inMB,
       replace([%ofFreeSpace], '.', ',') [%ofFreeSpace],
       FileName
FROM @t
ORDER BY FreeSpaceinMB DESC

