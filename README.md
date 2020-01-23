# Search-RecipientPermissions

This script creates a simple view of important mailbox permissions when completing a staged hybrid mailbox migration. 

### DESCRIPTION

In a staged mailbox migration you need to be aware of permissions for groups of users. You will also likely want to disregard permissions of users who are being migrated at the same time. 

**Search-RecipientPermissions.ps1 [-InputData <File From Get-RecipientPermissions.ps1[CSV]>] [-InputUserBatch <Array[TXT]>] [-ExcludeUserBatchPermissions [Switch]] [-ExportCSV [Switch]]**

```Powershell
<#
.SYNOPSIS
This script creates a simple view of important mailbox permissions when completing a staged hybrid mailbox migration.  

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


```

