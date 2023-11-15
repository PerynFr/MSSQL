Get-Content "C:\temp\Settings.ini" | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
$server        = $h.Get_Item("centralServer")
$inventoryDB   = $h.Get_Item("inventoryDB")
$usingCredentials = 0

if($server.length -eq 0){
    Write-Host "You must provide a value for the 'centralServer' in your Settings.ini file!!!" -BackgroundColor Red
    exit
}
if($inventoryDB.length -eq 0){
    Write-Host "You must provide a value for the 'inventoryDB' in your Settings.ini file!!!" -BackgroundColor Red
    exit
}

if($h.Get_Item("username").length -gt 0 -and $h.Get_Item("password").length -gt 0){
    $usingCredentials = 1
    $username         = $h.Get_Item("username")
    $password         = $h.Get_Item("password")
}

#Function to execute queries (depending on if the user will be using specific credentials or not)
function Execute-Query([string]$query,[string]$database,[string]$instance){
    if($usingCredentials -eq 1){
        Invoke-Sqlcmd -Query $query -Database $database -ServerInstance $instance -Username $username -Password $password -ErrorAction Stop
    }
    else{
        Invoke-Sqlcmd -Query $query -Database $database -ServerInstance $instance -ErrorAction Stop
    }
}

#Central Database creation/verification
$centralDBCreationQuery = "
IF DB_ID('$($inventoryDB)') IS NULL
CREATE DATABASE $($inventoryDB)
"
Execute-Query $centralDBCreationQuery "master" $server

###############################
#Schemas creation/verification#
###############################
$auditSchemaCreationQuery = "
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'audit')
EXEC('CREATE SCHEMA [audit] AUTHORIZATION [dbo]')
"
Execute-Query $auditSchemaCreationQuery $inventoryDB $server

$inventorySchemaCreationQuery = "
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'inventory')
EXEC('CREATE SCHEMA [inventory] AUTHORIZATION [dbo]')
"
Execute-Query $inventorySchemaCreationQuery $inventoryDB $server

$monitoringSchemaCreationQuery = "
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'monitoring')
EXEC('CREATE SCHEMA [monitoring] AUTHORIZATION [dbo]')
"
Execute-Query $monitoringSchemaCreationQuery $inventoryDB $server

###################################################################################################
#Create the main table where you will store the information about all the instance under your care#
###################################################################################################
$mslTableCreationQuery = "
IF NOT EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[inventory].[MasterServerList]') and OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
CREATE TABLE [inventory].[MasterServerList](
	[serverId]                  [int] IDENTITY(1,1) NOT NULL,
	[server_name]               [nvarchar](128) NOT NULL,
	[instance]                  [nvarchar](128) NOT NULL,
	[ip]                        [nvarchar](39) NOT NULL,
    [port]                      [int] NOT NULL DEFAULT 1433,
    [trusted]                   [bit] DEFAULT 1,
    [is_active]                 [bit] DEFAULT 1

CONSTRAINT PK_MasterServerList PRIMARY KEY CLUSTERED (serverId),

CONSTRAINT UQ_instance UNIQUE(server_name,instance)
) ON [PRIMARY]

END
"
Execute-Query $mslTableCreationQuery $inventoryDB $server

#######################################
#Error log table creation/verification#
#######################################
$errorLogTableCreationQuery = "
IF NOT EXISTS (SELECT * FROM dbo.sysobjects where id = object_id(N'[monitoring].[ErrorLog]') and OBJECTPROPERTY(id, N'IsTable') = 1)
BEGIN
CREATE TABLE [monitoring].[ErrorLog](
    [serverId]        [int]NOT NULL,
    [script]          [nvarchar](64) NOT NULL,
    [message]         [nvarchar](MAX) NOT NULL,
    [error_timestamp] [datetime] NOT NULL
    
    CONSTRAINT FK_ErrorLog_MasterServerList FOREIGN KEY (serverId) REFERENCES inventory.MasterServerList(serverId) ON DELETE NO ACTION ON UPDATE CASCADE
)ON [PRIMARY]
END
"
Execute-Query $errorLogTableCreationQuery $inventoryDB $server

#Logic to populate the Master Server List using a .txt file
$flag = 0
foreach($line in Get-Content .\instances.txt){
    $insertMSLQuery = "INSERT INTO inventory.MasterServerList(server_name,instance,ip,port) VALUES($($line))"
    
    try{
        Execute-Query $insertMSLQuery $inventoryDB $server
    }
    catch{
        $flag = 1
        [string]$message = $_
        $query = "INSERT INTO monitoring.ErrorLog VALUES((SELECT serverId FROM inventory.MasterServerList WHERE CASE instance WHEN 'MSSQLSERVER' THEN server_name ELSE CONCAT(server_name,'\',instance) END = '$($server)'),'Create-Master-Server-List','"+$message.replace("'","''")+"',GETDATE())"
        Execute-Query $query $inventoryDB $server
    }
}
if($flag -eq 1){Write-Host "Check the monitoring.ErrorLog table!"}

Write-Host "Done!"