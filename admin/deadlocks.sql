SELECT db.name                  DBName,
       tl.request_session_id,
       wt.blocking_session_id,
       Object_name(p.OBJECT_ID) BlockedObjectName,
       tl.resource_type,
       h1.TEXT                  AS RequestingText,
       h2.TEXT                  AS BlockingTest,
       tl.request_mode
FROM   sys.dm_tran_locks AS tl
       INNER JOIN sys.databases db
               ON db.database_id = tl.resource_database_id
       INNER JOIN sys.dm_os_waiting_tasks AS wt
               ON tl.lock_owner_address = wt.resource_address
       INNER JOIN sys.partitions AS p
               ON p.hobt_id = tl.resource_associated_entity_id
       INNER JOIN sys.dm_exec_connections ec1
               ON ec1.session_id = tl.request_session_id
       INNER JOIN sys.dm_exec_connections ec2
               ON ec2.session_id = wt.blocking_session_id
       CROSS APPLY sys.Dm_exec_sql_text(ec1.most_recent_sql_handle) AS h1
       CROSS APPLY sys.Dm_exec_sql_text(ec2.most_recent_sql_handle) AS h2 

--------------
--Get active deadlocks:

SELECT
    SESSION_ID
    ,BLOCKING_SESSION_ID
FROM SYS.DM_EXEC_REQUESTS
WHERE BLOCKING_SESSION_ID != 0

--Get text of the query (And check if it is really important):
exec sp_whoisactive |session_id|


--Kill the deadlock (Use wisely):
kill |session_id|
