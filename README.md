# SQLAutoAddToView
Script to schedule that will automatically recreate a specified view to union multiple databases together, for when developers can't be bothered to use partitions in MS SQL...

# Requirements
- Requires the SqlServer module to be installed
- You must run the Export-PasswordWithAES.ps1 script prior to running the main script, so that the password files will exist, allowing the script to run without needing to prompt for credentials

# Configuration
```powershell
$UserName = "your_domain_username"
$ServerName = "sqlServerName"

# File names for the AES key and the password files
$AESFileName = "AESKey.key"
$PasswordFileName = "Password.pwd"

# Defaults to the files reside in the current directory of the execution
# Best idea would be to change them to a secure directory
$credentialPath = if($PSScriptRoot.Length -eq 0) { $pwd } else { $PSScriptRoot }
$AESKeyFilePath = "$currentDir\$AESFileName"
$PasswordFilePath = "$currentDir\$PasswordFileName"
```

