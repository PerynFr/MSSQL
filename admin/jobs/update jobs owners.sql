--обновляем владельцев джобов
update j
	set j.owner_sid = 0x010500000000000515000000C389FFD3F0DCE27D4124798D72100100

  from msdb..sysjobs j
	join msdb..sysjobsteps js on js.job_id = j.job_id
	where 1 =1 
	and name not like '!ADMIN%'
and enabled <> 1