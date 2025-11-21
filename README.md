# Domain-GPO-Refresher
A simple PowerShell script for domain admins to force Group Policy updates on computers in a chosen OU. It runs updates in parallel for speed and logs results to a file so you can quickly see which machines succeeded or failed.

## Download the Script
    
    git clone https://github.com/repo-ranger-source/Domain-GPO-Refresher.git


##   Edit the settings
- Update the `$TargetOU` variable with the OU you want to target  
- Adjust `$LogFile` if you want the results written somewhere else  
- Optionally set `$MaxJobs` to control how many computers are updated in parallel 

## Run PowerShell as Administrator
    .\Force-GPUpdate.ps1
