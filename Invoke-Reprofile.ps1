<#
.Synopsis
   Invoke-Reprofile is used to reprofile a remote users profile.
   Author:   Michael J. Thomas
   Created:  06/29/2019
   Modified: 06/29/2019
   Notes:    WinRM must be Configured on Remote Computers and Remote Users must be Logged off. I have other functions for doing that. Not included with this example at this time.
.DESCRIPTION
   Invoke-Reprofile renames the UserName to UserName.old in Users Folder, Backup User SID in Registry to Windows Temp Folder, and Renamed SID to SID.Old in ProfileList.
   If user profile is messed up on multiple systems, use this on multiple computers.
.EXAMPLE
   Invoke-Reprofile -ComputerName "Computer01" -UserName "User01"
.EXAMPLE
   Invoke-Reprofile -ComputerName "Computer01" -UserName "User01","User02"
.EXAMPLE
   Invoke-Reprofile -ComputerName "Computer01","Computer02" -UserName "User01"
.EXAMPLE
   Invoke-Reprofile -ComputerName "Computer01","Computer02" -UserName "User01","User02"
#>
function Invoke-ReProfile
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $ComputerName,
         [string[]]
        $UserName
    )

    Begin { Write-Host "Invoking ReProfile Process on $ComputerName" }
    Process
    {
Try{
Invoke-Command -ComputerName $ComputerName -ScriptBlock{
$SID = (New-Object System.Security.Principal.NTAccount($Using:UserName)).Translate([System.Security.Principal.SecurityIdentifier]).Value
$TimeStamp = Get-Date -format yyyy-MM-dd-mm-ss-ff
Rename-Item -path "$env:SystemDrive\Users\$Using:UserName" -newName "$Using:UserName.old" -Force -ErrorAction Stop
Reg Export "Hkey_local_Machine\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID" $env:windir\temp\$Using:UserName$TimeStamp.reg 
Rename-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID" -NewName "$($SID).old" -Force -ErrorAction Stop
#Option for Removing The User Registry Key
#Remove-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList\$SID"  -Force -Confirm:$false -Recurse
} -ErrorAction Stop

}
Catch{ Write-Host $_.Exception.Message -ForegroundColor Red  }
    }
    End { 
    Write-Host "Completed Changing $UserName.old in Users Folder, Backup Registry to Windows Temp Folder, and Renamed Users SID in Registry ProfileList to SID.Old" -ForegroundColor Green     
    Write-Host "Please have user login and copy their data from the $UserName.old Folder" -ForegroundColor Green
    }
}
