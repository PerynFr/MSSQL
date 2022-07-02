update js 
	set js.command = REPLACE (js.command, 'PRAVDAPRODDB,10400', 'SMSK01DB233, 10400')

  from msdb..sysjobs j
	join msdb..sysjobsteps js on js.job_id = j.job_id
	where 1 =1 
	and name not like '!ADMIN%'
and enabled <> 1 