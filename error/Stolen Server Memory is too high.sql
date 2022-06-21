/*
Stolen Server Memory is too high
https://dba.stackexchange.com/questions/117001/db-engine-stolen-server-memory-is-too-high
*/

--% украденой памяти
SELECT Now = GETDATE()
    ,StolenMemory = (
        SELECT cntr_value
        FROM sys.dm_os_performance_counters
        WHERE [counter_name] IN ('Stolen Server Memory (KB)')
        )
    ,StolenMemoryPercent = 100.0 * (
        SELECT cntr_value
        FROM sys.dm_os_performance_counters
        WHERE [counter_name] IN ('Stolen Server Memory (KB)')
        ) / (
        SELECT cntr_value
        FROM sys.dm_os_performance_counters
        WHERE [counter_name] IN ('Total Server Memory (KB)')
        )
