-- Отключение задач без слова "!ADMIN" в имени
DECLARE @job_id uniqueidentifier;

WHILE EXISTS
  (SELECT 1
   FROM msdb.dbo.sysjobs
   WHERE name NOT LIKE '%!ADMIN%'
     AND enabled != 0) BEGIN
SELECT @job_id = job_id
FROM msdb.dbo.sysjobs
WHERE name NOT LIKE '%!ADMIN%'
  AND enabled != 0;

-- Изменение статуса задачи на disabled
 EXEC msdb.dbo.sp_update_job @job_id = @job_id,
                             @enabled = 0;

END -- Отключение расписаний без слова "!ADMIN" в имени
DECLARE @schedule_id int;

WHILE EXISTS
  (SELECT 1
   FROM msdb.dbo.sysjobschedules a
   JOIN msdb.dbo.sysjobs b ON a.job_id = b.job_id
   JOIN msdb.dbo.sysschedules s ON s.schedule_id = a.schedule_id
   WHERE b.name NOT LIKE '%!ADMIN%'
     AND s.[enabled] = 1) BEGIN
SELECT @schedule_id = a.schedule_id
FROM msdb.dbo.sysjobschedules a
JOIN msdb.dbo.sysjobs b ON a.job_id = b.job_id
JOIN msdb.dbo.sysschedules s ON s.schedule_id = a.schedule_id
WHERE b.name NOT LIKE '%!ADMIN%'
  AND s.[enabled] = 1;

-- Изменение статуса расписания на disabled
 EXEC msdb.dbo.sp_update_schedule @schedule_id = @schedule_id,
                                  @enabled = 0;

END ------------------------

SELECT a.*
FROM msdb.dbo.sysjobschedules a
JOIN msdb.dbo.sysjobs b ON a.job_id = b.job_id
SELECT *
FROM msdb.dbo.sysjobs
SELECT s.schedule_id
FROM msdb.dbo.sysschedules AS s
WHERE s.[enabled] = 1
