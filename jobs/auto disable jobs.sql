-- Отключение задач без слова "!ADMIN" в имени
DECLARE @job_id uniqueidentifier;
WHILE EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name NOT LIKE '%!ADMIN%' and enabled != 0)
BEGIN
    SELECT @job_id = job_id FROM msdb.dbo.sysjobs WHERE name NOT LIKE '%!ADMIN%' and enabled != 0;
    -- Изменение статуса задачи на disabled
    EXEC msdb.dbo.sp_update_job
    @job_id = @job_id,
    @enabled = 0;
END

-- Отключение расписаний без слова "!ADMIN" в имени
DECLARE @schedule_id uniqueidentifier;
WHILE EXISTS (SELECT 1 FROM msdb.dbo.sysjobschedules a join msdb.dbo.sysjobs b on a.job_id = b.job_id  WHERE b.name NOT LIKE '%!ADMIN%'  and b.enabled != 0)
BEGIN
    SELECT @schedule_id = a.schedule_id FROM msdb.dbo.sysjobschedules a join msdb.dbo.sysjobs b on a.job_id = b.job_id  WHERE b.name NOT LIKE '%!ADMIN%'   and b.enabled != 0;
    -- Изменение статуса расписания на disabled
    EXEC msdb.dbo.sp_update_schedule
    @schedule_id = @schedule_id,
    @enabled = 0;
END

------------------------
SELECT * FROM msdb.dbo.sysjobschedules a join msdb.dbo.sysjobs b on a.job_id = b.job_id
SELECT * FROM msdb.dbo.sysjobs
