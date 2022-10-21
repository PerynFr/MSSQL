/*
Если у вас есть несколько экземпляров на вашем сервере, вы можете запустить следующий скрипт, 
чтобы получить представление о том, сколько транзакций произошло за последние 10 секунд во всех экземплярах.
*/
-- First PASS
DECLARE @First INT
DECLARE @Second INT
SELECT @First = cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Transactions/sec'
AND instance_name='_Total';
-- Following is the delay
WAITFOR DELAY '00:00:10'
-- Second PASS
SELECT @Second = cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Transactions/sec'
AND instance_name='_Total';
SELECT (@Second - @First) 'TotalTransactions'
GO


--Транзакции конкретного экземпляра
-- First PASS
DECLARE @First INT
DECLARE @Second INT
SELECT @First = cntr_value
FROM sys.dm_os_performance_counters
WHERE
OBJECT_NAME = 'MSSQL$VTBCBUAT01:Databases'  AND -- Change name of your server ' AND -- Change name of your server
counter_name = 'Transactions/sec' AND
instance_name = '_Total';
-- Following is the delay
WAITFOR DELAY '00:00:10'
-- Second PASS
SELECT @Second = cntr_value
FROM sys.dm_os_performance_counters
WHERE
OBJECT_NAME = 'MSSQL$VTBCBUAT01:Databases'  AND -- Change name of your server
counter_name = 'Transactions/sec' AND
instance_name = '_Total';
SELECT (@Second - @First) 'TotalTransactions'
GO

--Транзакции, специфичные для базы данных
-- First PASS
use master
go
DECLARE @First INT
DECLARE @Second INT
SELECT @First = cntr_value
FROM sys.dm_os_performance_counters
WHERE
OBJECT_NAME = 'MSSQL$VTBCBUAT01:Databases' AND -- Change name of your server ' AND -- Change name of your server
counter_name = 'Transactions/sec' AND
instance_name = 'Backoffice_UAT'; -- Change name of your database
-- Following is the delay
WAITFOR DELAY '00:00:10'
-- Second PASS
SELECT @Second = cntr_value
FROM sys.dm_os_performance_counters
WHERE
OBJECT_NAME = 'MSSQL$VTBCBUAT01:Databases' AND -- Change name of your server
counter_name = 'Transactions/sec' AND
instance_name = 'Backoffice_UAT'; -- Change name of your database
SELECT (@Second - @First) 'TotalTransactions'
GO
