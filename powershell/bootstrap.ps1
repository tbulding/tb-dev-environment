Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#region Package Providers
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#endregion

#region Initial tools
choco feature enable -n allowGlobalConfirmation
choco install git
choco install cmder
Install-Module posh-git -F
#endregion

#region Update PATH
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;C:\Program Files\Git\bin;C:\Program Files\Git\cmd"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
#endregion

#region environment repo
$destinationPath = 'c:\temp\dev-environment'
git clone 'https://github.com/tbulding/tb-dev-environment.git' $destinationPath
#endregion

#region Setup Environment
& "$destinationPath/powershell/setup-environment.ps1 -sourcepath $destinationPath"
#endregion

