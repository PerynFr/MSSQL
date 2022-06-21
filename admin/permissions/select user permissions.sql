--List all effective permissions for user test in database AdventureWorks2019
EXECUTE AS USER = 'test'
GO
USE AdventureWorks2019
GO
SELECT * FROM fn_my_permissions(null, 'database'); 
GO

--List all effective permission for other users
SELECT * FROM fn_my_permissions('test', 'login'); 
GO
SELECT * FROM fn_my_permissions('test', 'user'); 
GO
