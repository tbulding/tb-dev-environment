Set-ExecutionPolicy -ExecutionPolicy Unrestricted


#region Package Providers
Write-Output 'Installing Nuget'
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#endregion

#region Initial tools
Write-Output 'Installing Git'
Install-Package git -Confirm:$false -Force
Write-Output 'Installing posh-git'
Install-Module posh-git -Force
#endregion

#region Update PATH
Write-Output 'Updating PATH'
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;C:\Program Files\Git\bin;C:\Program Files\Git\cmd"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
#endregion

#region environment repo 
Write-Output 'Cloning the dev-environment repo'
$destinationPath = 'c:\temp\dev-environment'
Remove-Item  -Path $destinationPath -Force -Confirm:$false  -Recurse -ErrorAction Ignore
git clone 'https://github.com/tbulding/tb-dev-environment.git' $destinationPath
#endregion

#region Setup Environment
Write-Output 'Running setup-environment script'
& "$destinationPath/powershell/setup-environment.ps1" -sourcepath $destinationPath
#endregion

