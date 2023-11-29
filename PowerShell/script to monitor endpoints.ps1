param(
    [string]$Location = $PSScriptRoot,
    [string]$ServersFile = "$Location\servers.txt",
    [int]$PingCount = 1,
    [switch]$Forever,
    [int]$SleepSeconds = 5
)

begin {
    if($false -eq (Test-Path $ServersFile))
    {
        throw "servers.txt file not found"
    }
}

process {
    do
    {
        if($Forever.IsPresent)
        {
            clear
        }

        Get-Content $ServersFile | ForEach-Object -Parallel {
            $server = $_
    
            $status = [PSCustomObject]@{
                Server = $server
                Online = $false
                Message = $null
            }
    
            if([boolean]($server -as [ipaddress]))
            {
                $status.Online = ( (Test-Connection -Count $using:PingCount -TargetName $server -ErrorAction SilentlyContinue).Status -eq "Success")
            }
            else {
                # DNS entry
    
                $ip = (Resolve-DnsName -Name $server -ErrorAction SilentlyContinue)
    
                if([string]::IsNullOrEmpty($ip))
                {
                    # could not resolve!
                    $status.Message = "Could not resolve DNS entry"
                    $status.Online = $false
                }
                else {
                    $status.Online = ( (Test-Connection -Count $using:PingCount -TargetName $server -ErrorAction SilentlyContinue).Status -eq "Success")
                }
    
            }
            
    
            $status
        } -ThrottleLimit 10 | Format-Table Server, @{
            Label = "Online"
            Expression = {
                switch($_.Online)
                {
                    $true {
                        $color  = "92"; break
                    }
                    $false {
                        $color = "91"; break
                    }
                    default {$color = "0"}
                }

                $e = [char]27
                "$e[${color}m$($_.Online)${e}[0m"
            }
        }, Message

        if($Forever.IsPresent)
        {
            Start-Sleep -Seconds $SleepSeconds
        }
        
    } until($false -eq $Forever.IsPresent)
    
}

end {

}