EXEC sp_executesql N'
SELECT 
	OBJECT_NAME(OBJECT_ID) indexname,
	index_type_desc,
	index_level, 
	avg_fragmentation_in_percent,
	avg_page_space_used_in_percent,
	page_count 
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID(@objname), NULL, NULL , ''SAMPLED'') 
ORDER BY avg_fragmentation_in_percent DESC',N'@objname nvarchar(1000)',@objname =configuration_properties