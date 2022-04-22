xp_fixeddrives
DECLARE @name NVARCHAR(50),
              @db varchar(100) = NULL DECLARE db
CURSOR
FOR
SELECT name
FROM sys.databases order by name OPEN db FETCH NEXT
FROM db INTO @db WHILE @@FETCH_STATUS = 0 BEGIN DECLARE @cmd varchar(1024)
SELECT @db=isnull(@db, db_name())
SELECT @cmd='use ['+@db+']; 
	SELECT	db_name() [DB],
		isnull(ds.name,''Not Applicable'') as [FileGroup],
		df.file_id,
		df.name as [FileName],
		df.type_desc as [Type], 
		df.physical_name,size/128. [Size (MB)],
		CAST(FILEPROPERTY(df.name, ''SpaceUsed'') AS int)/128. [Used Space (MB)],
		size/128.0 - CAST(FILEPROPERTY(df.name, ''SpaceUsed'') AS int)/128. AS [Available Space (MB)],
		df.state_desc as [Status],
	 case 
		when df.max_size=-1 then ''Unlimited''
		else convert(varchar(50),ceiling(df.max_size/128.)) end as [Max Size (MB)],
	 case 
		when df.is_percent_growth=1 then convert(varchar(20),df.growth)+''%''
		else 
		convert(varchar(20),convert(int,df.growth/128.))+'' MB'' end as [Growth],
	 df.is_read_only,df.is_media_read_only,df.is_sparse
	FROM sys.database_files df 
		left join sys.data_spaces ds on df.data_space_id=ds.data_space_id 
	order by df.file_id;' EXEC (@cmd) FETCH NEXT
FROM db INTO @db END CLOSE db DEALLOCATE db
