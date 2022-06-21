use master
go
select name, create_date from sys.databases where name='tempDB'

use master
go
SELECT login_time as [SQL Server Instance Uptime] FROM sys.sysprocesses where spid=1;


--SQL Server 2008 
use master
go
select sqlserver_start_time as  [SQL Server Instance Uptime] from sys.dm_os_sys_info

