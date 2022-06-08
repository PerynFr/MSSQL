--права на просмотр кода хранимых процедур, read only access to stored procedure contents


grant view definition on schema::dbo to [CORP\adm_ADorofeeva]

sp_helprotect NULL, [CORP\adm_ADorofeeva]


SELECT N'GRANT VIEW DEFINITION ON ' + QUOTENAME(SPECIFIC_SCHEMA) + N'.' + QUOTENAME(SPECIFIC_NAME) + N' TO [CORP\adm_ADorofeeva];' FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = 'PROCEDURE';

--example:
GRANT VIEW DEFINITION ON [dbo].[usp_Job_QuikLockWarning] TO [CORP\adm_ADorofeeva];
GRANT VIEW DEFINITION ON [dbo].[ListDocuments] TO [CORP\adm_ADorofeeva];
GRANT VIEW DEFINITION ON [dbo].[usp_GetSigningScenariosCodes] TO [CORP\adm_ADorofeeva];
GRANT VIEW DEFINITION ON [dbo].[usp_Job_QuikLock] TO [CORP\adm_ADorofeeva];
GRANT VIEW DEFINITION ON [dbo].[usp_GetSigningScenariosDetail] TO [CORP\adm_ADorofeeva];
