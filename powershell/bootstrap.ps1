Set-ExecutionPolicy -ExecutionPolicy Unrestricted

Write-Host '
__/\\\\\\\\\\\\__________________________________________________/\\\\\\\\\________/\\\\\______________        
 _\/\\\////////\\\_____________________________________________/\\\////////_______/\\\///_______________       
  _\/\\\______\//\\\__________________________________________/\\\/_______________/\\\________/\\\\\\\\__      
   _\/\\\_______\/\\\_____/\\\\\\\\___/\\\____/\\\____________/\\\______________/\\\\\\\\\____/\\\////\\\_     
    _\/\\\_______\/\\\___/\\\/////\\\_\//\\\__/\\\____________\/\\\_____________\////\\\//____\//\\\\\\\\\_    
     _\/\\\_______\/\\\__/\\\\\\\\\\\___\//\\\/\\\_____________\//\\\_______________\/\\\_______\///////\\\_   
      _\/\\\_______/\\\__\//\\///////_____\//\\\\\_______________\///\\\_____________\/\\\_______/\\_____\\\_  
       _\/\\\\\\\\\\\\/____\//\\\\\\\\\\____\//\\\__________________\////\\\\\\\\\____\/\\\______\//\\\\\\\\__ 
        _\////////////_______\//////////______\///______________________\/////////_____\///________\////////___
'

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

