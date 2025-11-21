# Force Group Policy Update on OU Computers
# Notes: Run on a DC with Domain Admin rights. Requires AD module + WinRM enabled.

Import-Module ActiveDirectory

# === Settings ===
$TargetOU  = "OU=****,DC=****,DC=****"      # Change to your OU
$LogFile   = "C:\Logs\GPUpdateResults.txt"  # Log file
$MaxJobs   = 15                             # Max parallel jobs

# Start log
Add-Content $LogFile "`n--- GPUpdate run $(Get-Date) ---"

# Get computers from OU
$Computers = Get-ADComputer -SearchBase $TargetOU -Filter {Enabled -eq $true} | Select-Object -ExpandProperty Name
Write-Host "Found $($Computers.Count) computers in $TargetOU"

# Kick off jobs
$Jobs = @()
foreach ($Comp in $Computers) {
    while ($Jobs.Count -ge $MaxJobs) {
        $Jobs = $Jobs | Where-Object { $_.State -eq 'Running' }
        Start-Sleep 2
    }

    $Jobs += Start-Job -ScriptBlock {
        param($Computer,$LogFile)
        try {
            Invoke-Command -ComputerName $Computer -ScriptBlock { gpupdate /force } -ErrorAction Stop
            Add-Content $LogFile "$Computer : OK"
        } catch {
            Add-Content $LogFile "$Computer : FAIL - $($_.Exception.Message)"
        }
    } -ArgumentList $Comp,$LogFile
}

# Wait for jobs
Write-Host "Waiting for jobs to finish..."
Wait-Job -Job $Jobs | Out-Null
Receive-Job -Job $Jobs | Out-Null
Remove-Job -Job $Jobs

Write-Host "Done. Check $LogFile for results."
