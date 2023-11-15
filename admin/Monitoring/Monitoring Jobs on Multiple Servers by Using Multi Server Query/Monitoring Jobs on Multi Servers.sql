SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
--Checking for SQL Server verion
DECLARE @JobList TABLE (Servername varchar(128), Jobname varchar(500), Stage TINYINT);
DECLARE @Stage TINYINT
	
/*
== Stage Level == 
1 - Part 1 : Put Maintenance Mode Check
2 - Part 2 : Drop Replication Check
3 - Part 3 : Start Restore 
4 - Part 4 : Bring Replication Back and full refresh
5 - Part 5 : Bring all online
*/
SET @Stage = 1

INSERT INTO @JobList
SELECT 'MyServer1\SQLA', 'Test_OSQLFailed', 1
UNION ALL
SELECT 'MyServer1\SQLA', 'Test job', 1
UNION ALL
SELECT 'MyServer2\SQLB', 'Test job', 2
UNION ALL
SELECT 'MyServer2\SQLB', 'syspolicy_purge_history', 2
UNION ALL
SELECT 'MyServer3\SQLC', 'Expired subscription clean up', 1
UNION ALL
SELECT 'MyServer3\SQLC', 'Test job', 1


IF CONVERT(tinyint,(SUBSTRING(CONVERT(CHAR(1),SERVERPROPERTY('productversion')),1,1))) <> 8
BEGIN
	---This is for SQL 2k5 and SQL2k8 servers
	SET NOCOUNT ON
	SELECT j.name AS job_name,
	CASE j.enabled WHEN 1 THEN 'Enabled' Else 'Disabled' END AS job_status,
	CASE jh.run_status WHEN 0 THEN 'Error Failed'
					WHEN 1 THEN 'Succeeded'
					WHEN 2 THEN 'Retry'
					WHEN 3 THEN 'Cancelled'
					WHEN 4 THEN 'In Progress' ELSE
					'Status Unknown' END AS 'last_run_status',
	ja.run_requested_date as last_run_date,
	CONVERT(VARCHAR(10),CONVERT(DATETIME,RTRIM(19000101))+(jh.run_duration * 9 + jh.run_duration % 10000 * 6 + jh.run_duration % 100 * 10) / 216e4,108) AS run_duration,
	ja.next_scheduled_run_date
	FROM
		(msdb.dbo.sysjobactivity ja LEFT JOIN msdb.dbo.sysjobhistory jh ON ja.job_history_id = jh.instance_id)
		join msdb.dbo.sysjobs_view j on ja.job_id = j.job_id
		join @JobList jl on jl.Servername = @@servername and jl.Jobname = j.name and jl.Stage = @Stage
	WHERE ja.session_id=(SELECT MAX(session_id)  from msdb.dbo.sysjobactivity) 
	ORDER BY job_name,job_status
		
END
ELSE
BEGIN
	--This is for SQL2k servers
	SET NOCOUNT ON
	DECLARE @SQL VARCHAR(8000)
	--Getting information from sp_help_job to a temp table
	SET @SQL='
	SELECT job_id,name AS job_name,CASE enabled WHEN 1 THEN ''Enabled'' ELSE ''Disabled'' END AS job_status,
		CASE last_run_outcome WHEN 0 THEN ''Error Failed''
						WHEN 1 THEN ''Succeeded''
						WHEN 2 THEN ''Retry''
						WHEN 3 THEN ''Cancelled''
						WHEN 4 THEN ''In Progress'' ELSE
						''Status Unknown'' END AS  last_run_status,
		CASE RTRIM(last_run_date) WHEN 0 THEN 19000101 ELSE last_run_date END last_run_date,
		CASE RTRIM(last_run_time) WHEN 0 THEN 235959 ELSE last_run_time END last_run_time,
		CASE RTRIM(next_run_date) WHEN 0 THEN 19000101 ELSE next_run_date END next_run_date,
		CASE RTRIM(next_run_time) WHEN 0 THEN 235959 ELSE next_run_time END next_run_time,
		last_run_date AS lrd, last_run_time AS lrt
	INTO ##jobdetails
	FROM OPENROWSET(''sqloledb'', ''server=(local);trusted_connection=yes'', ''set fmtonly off exec msdb.dbo.sp_help_job'')'
	exec (@SQL)
	--Merging run date & time format, adding run duration and adding step description
	SELECT distinct
		jd.job_name,jd.job_status,jd.last_run_status,
		CONVERT(DATETIME,RTRIM(jd.last_run_date)) +(jd.last_run_time * 9 + jd.last_run_time % 10000 * 6 + jd.last_run_time % 100 * 10) / 216e4 AS last_run_date,
		CONVERT(VARCHAR(10),CONVERT(DATETIME,RTRIM(19000101))+(jh.run_duration * 9 + jh.run_duration % 10000 * 6 + jh.run_duration % 100 * 10) / 216e4,108) AS run_duration,
		CONVERT(DATETIME,RTRIM(jd.next_run_date)) +(jd.next_run_time * 9 + jd.next_run_time % 10000 * 6 + jd.next_run_time % 100 * 10) / 216e4 AS next_scheduled_run_date
	FROM (##jobdetails jd  
		LEFT JOIN  msdb.dbo.sysjobhistory jh ON jd.job_id=jh.job_id AND jd.lrd=jh.run_date AND jd.lrt=jh.run_time
		JOIN @JobList jl on jl.Jobname = jd.job_name and jl.Servername = @@servername and jl.Stage = @Stage) 
	WHERE step_id=0 or step_id is null
	ORDER BY jd.job_name,jd.job_status
	--dropping the temp table
	
	DROP TABLE ##jobdetails
END


                
                