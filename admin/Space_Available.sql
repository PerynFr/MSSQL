SELECT db_name() [DB],
       isnull(ds.name, 'Not Applicable') AS [FileGroup],
       df.file_id,
       df.name AS [FileName],
       df.type_desc AS [Type],
       df.physical_name,
       SIZE/128. [Size (MB)],
            CAST(FILEPROPERTY(df.name, 'SpaceUsed') AS int)/128. [Used Space (MB)],
            SIZE/128.0 - CAST(FILEPROPERTY(df.name, 'SpaceUsed') AS int)/128. AS [Available Space (MB)],
                 df.state_desc AS [Status],
                 CASE
                     WHEN df.max_size=-1 THEN 'Unlimited'
                     ELSE convert(varchar(50), ceiling(df.max_size/128.))
                 END AS [Max Size (MB)],
                 CASE
                     WHEN df.is_percent_growth=1 THEN convert(varchar(20), df.growth)+'%'
                     ELSE convert(varchar(20), convert(int,df.growth/128.))+' MB'
                 END AS [Growth],
                 df.is_read_only,
                 df.is_media_read_only,
                 df.is_sparse
FROM sys.database_files df
LEFT JOIN sys.data_spaces ds ON df.data_space_id=ds.data_space_id
ORDER BY df.file_id;
