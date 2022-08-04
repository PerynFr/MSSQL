--Obtain the list of accounts that have direct access to the server-level permission 'Alter trace' by running the following query:
SELECT
who.name AS [Principal Name],
who.type_desc AS [Principal Type],
who.is_disabled AS [Principal Is Disabled],
what.state_desc AS [Permission State],
what.permission_name AS [Permission Name]
FROM
sys.server_permissions what
INNER JOIN sys.server_principals who
ON who.principal_id = what.grantee_principal_id
WHERE
what.permission_name = 'Alter trace'
AND who.name NOT LIKE '##MS%##'
AND who.type_desc <> 'SERVER_ROLE'
ORDER BY
who.name
;
GO
/*
If any user accounts have direct access to the 'Alter trace' permission, this is a finding.

Alternatively, to provide a combined list for all requirements of this type:
*/

SELECT
what.permission_name AS [Permission Name],
what.state_desc AS [Permission State],
who.name AS [Principal Name],
who.type_desc AS [Principal Type],
who.is_disabled AS [Principal Is Disabled]
FROM
sys.server_permissions what
INNER JOIN sys.server_principals who
ON who.principal_id = what.grantee_principal_id
WHERE
what.permission_name IN
(
'Administer bulk operations',
'Alter any availability group',
'Alter any connection',
'Alter any credential',
'Alter any database',
'Alter any endpoint ',
'Alter any event notification ',
'Alter any event session ',
'Alter any linked server',
'Alter any login',
'Alter any server audit',
'Alter any server role',
'Alter resources',
'Alter server state ',
'Alter Settings ',
'Alter trace',
'Authenticate server ',
'Control server',
'Create any database ',
'Create availability group',
'Create DDL event notification',
'Create endpoint',
'Create server role',
'Create trace event notification',
'External access assembly',
'Shutdown',
'Unsafe Assembly',
'View any database',
'View any definition',
'View server state'
)
AND who.name NOT LIKE '##MS%##'
AND who.type_desc <> 'SERVER_ROLE'
ORDER BY
what.permission_name,
who.name
;
GO

-- To Grant access to a Windows Login
/*
USE Master;
GO
GRANT ALTER TRACE TO [DomainNAME\WindowsLogin]
GO
*/
--Remove the 'Alter trace' permission access from the account that has direct access by running the following script:
/*
USE master;
GO
REVOKE ALTER TRACE FROM [DomainNAME\WindowsLogin]
GO
*/