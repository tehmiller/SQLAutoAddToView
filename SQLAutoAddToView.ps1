#Requires -Modules SqlServer
import-module SqlServer

function Import-PasswordWithAES
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string] $AESKeyFileName = "AESKey.key",
        [Parameter(Mandatory=$false)]
        [string] $PasswordFileName = "Password.pwd"
    )

    Process
    {
        $AESKey = Get-Content $AESKeyFileName
        $pwdTxt = Get-Content $PasswordFileName
        $securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey

        Write-Output $securePwd
    }
}

function Get-CredentialWithAES
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string] $UserName,
        [Parameter(Mandatory=$false)]
        [string] $AESKeyFileName = "AESKey.key",
        [Parameter(Mandatory=$false)]
        [string] $PasswordFileName = "Password.pwd"
    )

    Process
    {
        $securePwd = Import-PasswordWithAES -AESKeyFileName $AESKeyFileName -PasswordFileName $PasswordFileName
        $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
        Write-Output $credObject
    }
}

# Variable Configuration

$UserName = "eas2@highpoint.edu"
$ServerName = "vprodsec002"

# File names for the AES key and the password files
$AESFileName = "AESKey.key"
$PasswordFileName = "Password.pwd"

# Defaults to the files reside in the current directory of the execution
# Best idea would be to change them to a secure directory
$credentialPath = if($PSScriptRoot.Length -eq 0) { $pwd } else { $PSScriptRoot }
$AESKeyFilePath = "$credentialPath\$AESFileName"
$PasswordFilePath = "$credentialPath\$PasswordFileName"

<# 
# Password is generated with the function Export-PasswordWithAES
# this will generate a Password.pwd and an AESKey.key file in the directory it was run,
# place those files in the same directory as this script to allow automated running
#>

$cred = Get-CredentialWithAES -UserName $UserName -AESKeyFileName $AESKeyFilePath -PasswordFileName $PasswordFilePath

# Get the SQL instance
# For some strange reason, the Get-SqlInstance cmdlet doesn't like the default instance unless you pipe the servername to it
$AllInstances = @($ServerName) | % { Get-SqlInstance -ServerInstance $_ }
$Instance = $($AllInstances | ? { $_.InstanceName -eq "" })[0] # we only care about the default instance
$Databases = $Instance | Get-SqlDatabase | ? { $_.Name -like "ACVSUJournal*" }

$cmd = "ALTER VIEW ACVSUJournalLog as `r`n"
$i = 1
$innerCmd = ""
foreach ($db in $Databases)
{
    $line = "Select * from " + $db.Name + ".dbo.ACVSUJournalLog WHERE (MessageType LIKE '%Admit%') `r`n"
    $innerCmd = $innerCmd + $line
    if($i -lt $Databases.Length)
    {
        $innerCmd = $innerCmd + "UNION ALL`r`n"
    }
    $i++
}
$cmd = $cmd + $innerCmd

Write-Debug "Running query against $ServerName`r`n"
Write-Debug $cmd

Invoke-Sqlcmd -Query $cmd -ServerInstance $Instance -Database "HPUView"