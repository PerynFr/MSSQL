---удалить базу но оставить файлы  
USE [master]
GO
ALTER DATABASE [DBName] SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE [DBName]
GO

  
---удалить буду и файлы  
USE [master]
GO
ALTER DATABASE [DBName] set single_user with rollback immediate;
GO
DROP DATABASE [DBName]
GO

