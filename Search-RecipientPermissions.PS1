<#
.SYNOPSIS
This script creates a simple view of important mailbox permissions when completing a staged mailbox migration.  

.DESCRIPTION
In a staged mailbox migration you need to be aware of permissions for groups of users. You will also likely want to disregard permissions of users who are being migrated at the same time. 

Search-RecipientPermissions.ps1 [-InputData <File From Get-RecipientPermissions.ps1[CSV]>] [-InputUserBatch <Array[TXT]>] [-ExcludeUserBatchPermissions [Switch]] [-ExportCSV [Switch]]

.PARAMETER InputData
Specifies the file path to the CSV file which was output from the Get-RecipientPermissions.ps1 Script. See Notes

.PARAMETER InputUserBatches
Specifies the SamAccountNames of all the users in the batch from a TXT file or array as a string. "User1","User2"

.PARAMETER ExcludeUserBatchPermissions
This Switch removes all permissions of users who will be migrated within the same batch of users. 

.PARAMETER ExportCSV
Specifies that all results will be exported to a CSV file. This is a switch only and the filename will be set via the  script  in the  format of 20180508T014040Z.csv

.EXAMPLE
Search-RecipientPermissions.ps1 -InputData 20180508T014040Z.csv -InputUserBatch "UserSamAccountName1","UserSamAccountName2"

-- INPUT USER BATCH VIA STRING --

Searches for all permissions related to User1 and User2. 

.EXAMPLE
Search-RecipientPermissions.ps1 -InputData 20180508T014040Z.csv -InputUserBatch "UserSamAccountName1","UserSamAccountName2" -ExportCSV

-- CREATE CSV REPORT VIA INPUT USER BATCH VIA STRING --

Searches for all permissions related to User1 and User2 and creates a CSV file containing all permission infomation for these 2 users in the location where the script is run.

.EXAMPLE
Search-RecipientPermissions.ps1 -InputData 20180508T014040Z.csv -InputUserBatch C:\UserBatch1.txt -ExcludeUserBatchPermissions -ExportCSV

-- FIND PERMISSIONS ON A BULK NUMBER OF USERS WITH CSV EXPORT --

Searches for all permissions related to SamAccountNames listed in the UserBatch1.txt and creates a CSV file of of permissions that exisit outside the batch. 

.LINK
 
Get-RecipientPermissions.ps1 - https://github.com/JBines/Get-RecipientPermissions.ps1

Exchange Hybrid Deployment Considerations - https://technet.microsoft.com/library/jj200581(v=exchg.150).aspx

.NOTES
Important! This script evalutates the data you have already collected which can take hours or days to complete. Use the Get-RecipientPermissions.ps1 to create a CSV which contains ALL recipient permissions Exchange Org. 

The Get-RecipientPermissions.ps1 is a PowerShell script that will report on permissions for one or many recipients. This script includes the function to remove permissions which are deemed as orphaned such as a Deleted Accounts or Disconnected Mailbox Accounts.

[AUTHOR]
 Joshua Bines, Consultant

Find me on:
* Web:	    https://theinformationstore.com.au
* LinkedIn:	https://www.linkedin.com/in/joshua-bines-4451534
* Github:	https://github.com/jbines
 
[VERSION HISTORY / UPDATES]
 0.0.1 20190902 - JBINES - Created the bare bones
 0.0.2 20200103 - JBINES - Updated after an update from the Get-RecipientPermissions.ps1 script.
                         - Add csv and txt file support

[TO DO LIST / PRIORITY]
 LOW - Nothing that I can think of... yet...

#>

Param 
(
	[Parameter(Position=0, Mandatory = $True, HelpMessage="Please provide Input Data File in a CSV format")]
    [ValidateNotNullOrEmpty()]
    $InputData,
	[Parameter(Position=1, Mandatory = $True, HelpMessage="Please provide the Samaccount name of the User you would like to check?")]
    [ValidateNotNullOrEmpty()]
    $InputUserBatch,
    [Parameter(Mandatory = $False)]
    [Switch]$ExportCSV=$False,
    [Parameter(Mandatory = $False)]
    [Switch]$ExcludeUserBatchPermissions=$False
)

Begin{

    #Start Script Timing StopWatch
    $TotalScriptStopWatch = [system.diagnostics.stopwatch]::startNew()
    
    #Import Data File
    $dataimport = Import-Csv -Path $InputData

    #Check for file Extenstion - Watchout for for users with .txt in the name
    if($InputUserBatch -like "*.txt"){

        $InputUserBatch = Get-Content $InputUserBatch

    }

    #Check Array Input values 
    if((-not($dataimport | Get-Member | where-Object {$_.name -eq 'RecipientSamAccountName'}))-xor(-not($dataimport | Get-Member | where-Object {$_.name -eq 'SourceRecipientSamAccountName'}))){

        Write-Log -LogLevel ERROR -Message "CSV File is missing Recipient SamAccountName or Source Recipient SamAccountName"  
        Break
    }
    
    #Create Array
    $Userarray = @()

    function Write-Log([string[]]$Message, [string]$LogFile = $Script:LogFile, [switch]$ConsoleOutput, [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")][string]$LogLevel)
    {
           $Message = $Message + $Input
           If (!$LogLevel) { $LogLevel = "INFO" }
           switch ($LogLevel)
           {
                  SUCCESS { $Color = "Green" }
                  INFO { $Color = "White" }
                  WARN { $Color = "Yellow" }
                  ERROR { $Color = "Red" }
                  DEBUG { $Color = "Gray" }
           }
           if ($Message -ne $null -and $Message.Length -gt 0)
           {
                  $TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
                  if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty)
                  {
                         Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] [$LogLevel] $Message"
                  }
                  if ($ConsoleOutput -eq $true)
                  {
                         Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color
                    if($AutomationPSCredential)
                    {
                         Write-Output "[$TimeStamp] [$LogLevel] :: $Message"
                    } 

                  }
           }
    } #End Write-Log
    
}#End_Begin

Process{
    
    #Compile New Array for All Batch Users
    foreach($user in $InputUserBatch){

        $Userarray += $dataimport | Where-Object{$_.'RecipientSamAccountName' -eq $user}
        $Userarray += $dataimport | Where-Object{$_.'SourceRecipientSamAccountName' -eq $user} 

    }
    #Limit to uniquie values
    $UserBatchArray = $Userarray | Select-Object -Unique *

    #filter array with users in the array
    $result = @()

    if($ExcludeUserBatchPermissions){
        foreach($Permission in $UserBatchArray){

            $outsideBatchRecipient = $null
            $outsideBatchSource = $null
            
            try {
                $outsideBatchRecipient = Compare-Object -ReferenceObject $Permission.'RecipientSamAccountName' -DifferenceObject $InputUserBatch -IncludeEqual | ?{$_.SideIndicator -eq "<="}
            }
            catch {
                
            }

            try {
                $outsideBatchSource = Compare-Object -ReferenceObject $Permission.'SourceRecipientSamAccountName' -DifferenceObject $InputUserBatch -IncludeEqual | ?{$_.SideIndicator -eq "<="}
            }
            catch {
                
            }

            #$outsideBatchRecipient
            #$outsideBatchSource

            #Check each user in the batch

            if(($outsideBatchRecipient.SideIndicator -eq "<=") -xor ($outsideBatchSource.SideIndicator -eq "<=")){

                $result += $Permission
                $UserBatchArray = $result
            }
        }

    }   

    #Print Table to Screen
    $UserBatchArray | Format-Table SourceRecipient,Recipient,RecipientSamAccountName,PermissionType

}

 END {
    
 if($exportCSV){
        
        Write-Verbose "Exporting to CSV with path of $($exportpath)$(((get-date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ")).csv"
            If($WhatIfPreference -eq $True){
            
                $WhatIfPreference = $False
                
                $report | Export-Csv -Path "$($exportpath)SearchOutput-$(((get-date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ")).csv" -Encoding UTF8
                
                $WhatIfPreference = $True
            
            }
    
            Else {
            
                $report | Export-Csv -Path "$($exportpath)$(((get-date).ToUniversalTime()).ToString("yyyyMMddThhmmssZ")).csv" -Encoding UTF8
            
            }   
        
 }

#Stop Script Stopwatch and Report
    $TotalScriptStopWatch.Stop() 
    Write-Host "Script Completed in $($TotalScriptstopwatch.Elapsed.TotalMinutes) Minutes"
    
 }
    
