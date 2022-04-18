/*
Execute the following set of queries:
https://stackoverflow.com/questions/52325737/how-to-fix-recovery-pending-state-in-sql-server-database
*/

ALTER DATABASE [DBName] SET EMERGENCY;
GO

ALTER DATABASE [DBName] set single_user
GO

DBCC CHECKDB ([DBName], REPAIR_ALLOW_DATA_LOSS) WITH ALL_ERRORMSGS;
GO 

ALTER DATABASE [DBName] set multi_user
GO
