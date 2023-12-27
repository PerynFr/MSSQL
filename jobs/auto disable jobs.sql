-- Отключение задач без слова "!ADMIN" в имени
DECLARE @job_id INT;

WHILE EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name NOT LIKE '%!ADMIN%')
BEGIN
    SELECT @job_id = job_id FROM msdb.dbo.sysjobs WHERE name NOT LIKE '%!ADMIN%';

    -- Изменение статуса задачи на disabled
    EXEC msdb.dbo.sp_update_job
    @job_id = @job_id,
    @enabled = 0;
END

-- Отключение расписаний без слова "!ADMIN" в имени
DECLARE @schedule_id INT;

WHILE EXISTS (SELECT 1 FROM msdb.dbo.sysjobschedules WHERE name NOT LIKE '%!ADMIN%')
BEGIN
    SELECT @schedule_id = schedule_id FROM msdb.dbo.sysjobschedules WHERE name NOT LIKE '%!ADMIN%';

    -- Изменение статуса расписания на disabled
    EXEC msdb.dbo.sp_update_schedule
    @schedule_id = @schedule_id,
    @enabled = 0;
END
