
SELECT 'max connections = ' + cast(@@MAX_CONNECTIONS AS varchar(20)) 
	+ ' curent connctions = ' + cast(@@connections AS varchar(20))


SELECT CASE
           WHEN serverproperty('IsClustered')=1 THEN serverproperty('ComputerNamePhysicalNetBIOS')
           ELSE 'not clustered'
       END 'Current Cluster Node',

  (SELECT ceiling(physical_memory_kb/1024.)
   FROM sys.dm_os_sys_info) [Physical Memory (MB)],

  (SELECT cntr_value/1024
   FROM master..sysperfinfo
   WHERE counter_name = 'Total Server Memory (KB)') [Current Memory (MB)],

  (SELECT cntr_value/1024
   FROM master..sysperfinfo
   WHERE counter_name = 'Target Server Memory (KB)') [Target Memory (MB)],

  (SELECT value_in_use
   FROM master.sys.configurations
   WHERE name in ('min server memory (MB)')) [Min Server Memory],

  (SELECT value_in_use
   FROM master.sys.configurations
   WHERE name in ('max server memory (MB)')) [Max Server Memory]

/*
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'max server memory', 4096; --MB
GO
RECONFIGURE;
GO
*/
