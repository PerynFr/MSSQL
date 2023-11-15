Get-Content "C:\temp\Settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$server        = $h.Get_Item("centralServer")
$inventoryDB   = $h.Get_Item("inventoryDB")

if($server.length -eq 0){
    Write-Host "You must provide a value for the 'centralServer' in your Settings.ini file!!!" -BackgroundColor Red
    exit
}
if($inventoryDB.length -eq 0){
    Write-Host "You must provide a value for the 'inventoryDB' in your Settings.ini file!!!" -BackgroundColor Red
    exit
}

$mslExistenceQuery = "
SELECT Count(*) FROM dbo.sysobjects where id = object_id(N'[inventory].[MasterServerList]') and OBJECTPROPERTY(id, N'IsTable') = 1
"
$result = Invoke-Sqlcmd -Query $mslExistenceQuery -Database $inventoryDB -ServerInstance $server -ErrorAction Stop 

if($result[0] -eq 0){
    Write-Host "The table [inventory].[MasterServerList] wasn't found!!!" -BackgroundColor Red 
    exit
}

$enoughInstancesInMSLQuery = "
SELECT COUNT(*) FROM inventory.MasterServerList WHERE is_active = 1
"
$result = Invoke-Sqlcmd -Query $enoughInstancesInMSLQuery -Database $inventoryDB -ServerInstance $server -ErrorAction Stop 

if($result[0] -eq 0){
    Write-Host "There are no active instances registered to work with!!!" -BackgroundColor Red 
    exit
}

if ($h.Get_Item("username").length -gt 0 -and $h.Get_Item("password").length -gt 0) {
    $username   = $h.Get_Item("username")
    $password   = $h.Get_Item("password")
}

#Function to execute queries (depending on if the user will be using specific credentials or not)
function Execute-Query([string]$query,[string]$database,[string]$instance,[int]$trusted){
    if($trusted -eq 1){ 
        try{
            Invoke-Sqlcmd -Query $query -Database $database -ServerInstance $instance -ErrorAction Stop
        }
        catch{
            [string]$message = $_
            $errorQuery = "INSERT INTO monitoring.ErrorLog VALUES((SELECT serverId FROM inventory.MasterServerList WHERE CASE instance WHEN 'MSSQLSERVER' THEN server_name ELSE CONCAT(server_name,'\',instance) END = '$($instance)'),'Get-MSSQL-Instance-Jobs','"+$message.replace("'","''")+"',GETDATE())"
            Invoke-Sqlcmd -Query $errorQuery -Database $inventoryDB -ServerInstance $server -ErrorAction Stop
        }
    }
    else{
        try{
            Invoke-Sqlcmd -Query $query -Database $database -ServerInstance $instance -Username $username -Password $password -ErrorAction Stop
        }
        catch{
            [string]$message = $_
            $errorQuery = "INSERT INTO monitoring.ErrorLog VALUES((SELECT serverId FROM inventory.MasterServerList WHERE CASE instance WHEN 'MSSQLSERVER' THEN server_name ELSE CONCAT(server_name,'\',instance) END = '$($instance)'),'Get-MSSQL-Instance-Jobs','"+$message.replace("'","''")+"',GETDATE())"
            Invoke-Sqlcmd -Query $errorQuery -Database $inventoryDB -ServerInstance $server -ErrorAction Stop
        }
    }
}

###############################
#Jobs inventory table creation#
###############################
$jobsInventoryTableQuery = "
IF NOT EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[inventory].[Jobs]') and OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
CREATE TABLE [inventory].[Jobs](
    [serverId]                  [INT]NOT NULL,
    [job_name]                  [VARCHAR](128) NOT NULL,
    [is_enabled]                [TINYINT] NULL,
    [owner]                     [VARCHAR](32) NULL,
    [date_created]              [DATETIME] NULL,
    [date_modified]             [DATETIME] NULL,
    [frequency]                 [VARCHAR](32) NULL,
    [days]                      [VARCHAR](64) NULL,
    [execution_time]            [VARCHAR](64) NULL,
    [data_collection_timestamp] [DATETIME] NOT NULL

    CONSTRAINT PK_JobsInventory PRIMARY KEY CLUSTERED (serverId,job_name),

    CONSTRAINT FK_JobsInventory_MasterServerList FOREIGN KEY (serverId) REFERENCES inventory.MasterServerList(serverId) ON DELETE NO ACTION ON UPDATE NO ACTION,

) ON [PRIMARY]
END
"
Execute-Query $jobsInventoryTableQuery $inventoryDB $server 1

#TRUNCATE the inventory.Jobs table to always store a fresh copy of the information from all the instances
Execute-Query "TRUNCATE TABLE inventory.Jobs" $inventoryDB $server 1

#Select the instances from the Master Server List that will be traversed
$instanceLookupQuery = "
SELECT
        serverId,
        trusted,
		CASE instance 
			WHEN 'MSSQLSERVER' THEN server_name                                   
			ELSE CONCAT(server_name,'\',instance)
		END AS 'instance',
		CASE instance 
			WHEN 'MSSQLSERVER' THEN ip                                   
			ELSE CONCAT(ip,'\',instance)
		END AS 'ip',
        CONCAT(ip,',',port) AS 'port'
FROM inventory.MasterServerList
WHERE is_active = 1
"
$instances = Execute-Query $instanceLookupQuery $inventoryDB $server 1

#For each instance, fetch the desired information
$jobsInformationQuery = "
SELECT
	SERVERPROPERTY('SERVERNAME') AS 'instance',
	sysjobs.name AS 'name',
	sysjobs.enabled AS 'enabled',
	SUSER_SNAME(sysjobs.owner_sid) AS 'owner',
	sysjobs.date_created AS 'date_created',
	sysjobs.date_modified AS 'date_modified',
	CASE
		WHEN freq_type = 4 THEN 'Daily'
	END AS 'frequency',
	'Every ' + CAST (freq_interval AS VARCHAR(3)) + ' day(s)' AS 'days',
	CASE
		WHEN freq_subday_type = 2 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' seconds ' + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
		WHEN freq_subday_type = 4 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' minutes ' + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
		WHEN freq_subday_type = 8 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' hours '   + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
		ELSE 'Starting at ' 
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
	END AS 'execution_time'
FROM msdb.dbo.sysjobs
JOIN msdb.dbo.sysjobschedules ON sysjobs.job_id = sysjobschedules.job_id
JOIN msdb.dbo.sysschedules ON sysjobschedules.schedule_id = sysschedules.schedule_id
WHERE freq_type = 4

UNION

-- jobs with a weekly schedule
SELECT
	SERVERPROPERTY('SERVERNAME') AS 'instance',
	sysjobs.name AS 'name',
	sysjobs.enabled AS 'enabled',
	SUSER_SNAME(sysjobs.owner_sid) AS 'owner',
	sysjobs.date_created AS 'date_created',
	sysjobs.date_modified AS 'date_modified',
	CASE	
		WHEN freq_type = 8 THEN 'Weekly'
	END AS 'frequency',
	CASE WHEN freq_interval&2 = 2 THEN 'Monday, ' ELSE '' END
	+CASE WHEN freq_interval&4 = 4 THEN 'Tuesday, ' ELSE '' END
	+CASE WHEN freq_interval&8 = 8 THEN 'Wednesday, ' ELSE '' END
	+CASE WHEN freq_interval&16 = 16 THEN 'Thursday, ' ELSE '' END
	+CASE WHEN freq_interval&32 = 32 THEN 'Friday, ' ELSE '' END
	+CASE WHEN freq_interval&64 = 64 THEN 'Saturday, ' ELSE '' END
	+CASE WHEN freq_interval&1 = 1 THEN 'Sunday' ELSE '' END
	AS 'Days',
	CASE
		WHEN freq_subday_type = 2 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' seconds ' + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') 
		WHEN freq_subday_type = 4 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' minutes ' + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
		WHEN freq_subday_type = 8 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' hours '   + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
		ELSE 'Starting at ' 
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
	END AS 'execution_time'
	FROM msdb.dbo.sysjobs
JOIN msdb.dbo.sysjobschedules ON sysjobs.job_id = sysjobschedules.job_id
JOIN msdb.dbo.sysschedules ON sysjobschedules.schedule_id = sysschedules.schedule_id
WHERE freq_type = 8
UNION

-- jobs with a monthly schedule
SELECT
	SERVERPROPERTY('SERVERNAME') AS 'instance',
	sysjobs.name AS 'name',
	sysjobs.enabled AS 'enabled',
	SUSER_SNAME(sysjobs.owner_sid) AS 'owner',
	sysjobs.date_created AS 'date_created',
	sysjobs.date_modified AS 'date_modified',
	CASE	
		WHEN freq_type = 16 THEN 'Monthly'
	END AS 'frequency',
	CASE WHEN freq_interval&2 = 2 THEN 'Monday, ' ELSE '' END
	+CASE WHEN freq_interval&4 = 4 THEN 'Tuesday, ' ELSE '' END
	+CASE WHEN freq_interval&8 = 8 THEN 'Wednesday, ' ELSE '' END
	+CASE WHEN freq_interval&16 = 16 THEN 'Thursday, ' ELSE '' END
	+CASE WHEN freq_interval&32 = 32 THEN 'Friday, ' ELSE '' END
	+CASE WHEN freq_interval&64 = 64 THEN 'Saturday, ' ELSE '' END
	+CASE WHEN freq_interval&1 = 1 THEN 'Sunday' ELSE '' END
	AS 'Days',
	CASE
		WHEN freq_subday_type = 2 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' seconds ' + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') 
		WHEN freq_subday_type = 4 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' minutes ' + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
		WHEN freq_subday_type = 8 THEN 'Every ' + CAST(freq_subday_interval AS VARCHAR(7)) 
		+ ' hours '   + 'starting at '
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
		ELSE 'Starting at ' 
		+ STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
	END AS 'execution_time'
FROM msdb.dbo.sysjobs
JOIN msdb.dbo.sysjobschedules ON sysjobs.job_id = sysjobschedules.job_id
JOIN msdb.dbo.sysschedules ON sysjobschedules.schedule_id = sysschedules.schedule_id
WHERE freq_type = 16
ORDER BY name
"

foreach ($instance in $instances){
   if($instance.trusted -eq 'True'){$trusted = 1}else{$trusted = 0}
   $sqlInstance = $instance.instance

   #Go grab the complementary information for the instance
   Write-Host "Fetching jobs information from instance" $instance.instance
   
   #Special logic for cases where the instance isn't reachable by name
   try{
        $results = Execute-Query $jobsInformationQuery "master" $sqlInstance $trusted
   }
   catch{
        $sqlInstance = $instance.ip
        [string]$message = $_
        $query = "INSERT INTO monitoring.ErrorLog VALUES("+$instance.serverId+",'Get-MSSQL-Instance-Jobs','"+$message.replace("'","''")+"',GETDATE())"
        Execute-Query $query $inventoryDB $server 1

        try{  
            $results = Execute-Query $jobsInformationQuery "master" $sqlInstance $trusted
        }
        catch{
            $sqlInstance = $instance.port
            [string]$message = $_
            $query = "INSERT INTO monitoring.ErrorLog VALUES("+$instance.serverId+",'Get-MSSQL-Instance-Jobs','"+$message.replace("'","''")+"',GETDATE())"
            Execute-Query $query $inventoryDB $server 1

            try{
                $results = Execute-Query $jobsInformationQuery "master" $sqlInstance $trusted
            }
            catch{
                [string]$message = $_
                $query = "INSERT INTO monitoring.ErrorLog VALUES("+$instance.serverId+",'Get-MSSQL-Instance-Jobs','"+$message.replace("'","''")+"',GETDATE())"
                Execute-Query $query $inventoryDB $server 1
            }
        }
   }
   
   #Perform the INSERT in the inventory.Jobs only if it returns information
   if($results.Length -ne 0){

      #Build the insert statement
      $insert = "INSERT INTO inventory.Jobs VALUES"
      foreach($result in $results){   
         $insert += "
         (
          '"+$instance.serverId+"',
          '"+$result['name']+"',
           "+$result['enabled']+",
          '"+$result['owner']+"',
          '"+$result['date_created']+"',
          '"+$result['date_modified']+"',
          '"+$result['frequency']+"',
          '"+$result['days']+"',
          '"+$result['execution_time']+"',
          GETDATE()
         ),
         "
       }

       $insert = $insert -replace "''",'NULL'
       $insert = $insert -replace "NULLNULL",'NULL'
       Execute-Query $insert.Substring(0,$insert.LastIndexOf(',')) $inventoryDB $server 1
   }
}

Write-Host "Done!"
