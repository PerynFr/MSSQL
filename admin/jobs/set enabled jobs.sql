update j 
	set j.enabled = 1

  from msdb..sysjobs j
	join msdb..sysjobsteps js on js.job_id = j.job_id
	where 1 =1 
	and name not like '!ADMIN%'
and enabled <> 1 