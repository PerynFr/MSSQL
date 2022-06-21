--List all effective permissions for user test in database AdventureWorks2019
EXECUTE AS USER = 'test'
GO
USE AdventureWorks2019
GO
SELECT * FROM fn_my_permissions(null, 'database'); 
GO
