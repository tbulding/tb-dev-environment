Import-Module -Name 'C:\Program Files\WindowsPowerShell\Modules\posh-git\0.7.3\posh-git.psm1'
Import-Module -Name 'C:\Program Files\WindowsPowerShell\Modules\oh-my-posh\2.0.249\oh-my-posh.psm1'
Import-Module -Name 'C:\Program Files\WindowsPowerShell\Modules\AWSPowerShell\3.3.485.0\AWSPowerShell.dll'
Import-Module -Name 'C:\Program Files\WindowsPowerShell\Modules\Get-ChildItemColor\1.2.3\Get-ChildItemColor.psm1'
Import-Module -Name 'C:\Program Files\WindowsPowerShell\Modules\PSReadline\2.0.0\PSReadLine.psm1'

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# AWS Profile
#Update AWS Profile - Delays profile by 6s
Set-AWSCredential -AccessKey $config.aws.accesskey -SecretKey $config.aws.secretkey