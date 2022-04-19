USE msdb; 
GO
SELECT bs.database_name,
       bs.backup_start_date,
       bs.backup_finish_date,
       bs.server_name,
       bs.user_name,
       bs.type,
       bm.physical_device_name
FROM msdb.dbo.backupset AS bs
INNER JOIN msdb.dbo.backupmediafamily AS bm ON bs.media_set_id = bm.media_set_id
order by database_name, backup_start_date desc
