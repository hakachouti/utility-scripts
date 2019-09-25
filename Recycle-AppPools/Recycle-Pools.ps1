<#
.SYNOPSIS
    Recycle-AppPools
.DESCRIPTION
    Script that recycles app pools specified in an xml configuration file
.EXAMPLE
    ./Recycle-AppPools.ps1 -ConfPath config.xml
.NOTES
    Author : MCS
#>

param 
(
    [Parameter(Mandatory=$true)] [string] $ConfPath
)

try 
{

    $logPath = ".\recycle-apppools.log"
    Start-Transcript -Path $logPath -Force

    Write-Host "Recycle App Pools"
    $Conf = [xml] (Get-Content $ConfPath -Encoding UTF8)
    $ErrorCount = 0
    foreach($PoolName in $Conf.AppPools.AppPool){
        Write-Host "$(get-date -Format 'dd/MM/yyyy HH:m:ss') INFO: Recycling Pool $PoolName ..."
        try {
            Restart-WebAppPool -Name $PoolName -ErrorAction Stop
            Write-Host "$(get-date -Format 'dd/MM/yyyy HH:m:ss') INFO: Recycled Pool $PoolName"
        }
        catch {
            Write-Host "$(get-date -Format 'dd/MM/yyyy HH:m:ss') ERROR: Stacktrace : $($_.Exception.StackTrace)" -ForegroundColor:Red
            $ErrorCount++
        }
    }
}
catch
{
    Write-Host ""
    
    If ($null -ne $_.FullyQualifiedErrorId) 
    {
        Write-Host "$(get-date -Format 'dd/MM/yyyy HH:m:ss') ERROR: Stacktrace : $($_.Exception.Message)" -ForegroundColor:Red
    }
    exit 1;
}
finally
{
    Stop-Transcript
    if($ErrorCount -eq 0){
        exit 0
    }
    exit 2
}
