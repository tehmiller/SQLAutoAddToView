function Export-PasswordWithAES
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
        $Credential = Get-Credential

        # Generate a random AES Encryption Key.
        $AESKey = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
            
        # Store the AESKey into a file. This file should be protected!  (e.g. ACL on the file to allow only select people to read)
        Set-Content $AESKeyFileName $AESKey   # Any existing AES Key file will be overwritten		

        $password = $Credential.Password | ConvertFrom-SecureString -Key $AESKey
        Set-Content $PasswordFileName $password
    }
}

Export-PasswordWithAES