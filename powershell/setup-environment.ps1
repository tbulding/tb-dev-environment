[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $sourcepath
)
$toolsPath = 'C:\tools'

Write-Host '
__/\\\______________/\\\_____/\\\\\\\\\\\____/\\\______________________________/\\\\\\\\\________/\\\\\______________        
 _\/\\\_____________\/\\\___/\\\/////////\\\_\/\\\___________________________/\\\////////_______/\\\///_______________       
  _\/\\\_____________\/\\\__\//\\\______\///__\/\\\_________________________/\\\/_______________/\\\________/\\\\\\\\__      
   _\//\\\____/\\\____/\\\____\////\\\_________\/\\\________________________/\\\______________/\\\\\\\\\____/\\\////\\\_     
    __\//\\\__/\\\\\__/\\\________\////\\\______\/\\\_______________________\/\\\_____________\////\\\//____\//\\\\\\\\\_    
     ___\//\\\/\\\/\\\/\\\____________\////\\\___\/\\\_______________________\//\\\_______________\/\\\_______\///////\\\_   
      ____\//\\\\\\//\\\\\______/\\\______\//\\\__\/\\\________________________\///\\\_____________\/\\\_______/\\_____\\\_  
       _____\//\\\__\//\\\______\///\\\\\\\\\\\/___\/\\\\\\\\\\\\\\\______________\////\\\\\\\\\____\/\\\______\//\\\\\\\\__ 
        ______\///____\///_________\///////////_____\///////////////__________________\/////////_____\///________\////////___
'

#region *************** Download and Install cmder ***************************
#Check to see if cmder is already installed
Write-Output 'Preparing to install cmder'
if ((Test-Path 'c:\tools\cmder') -eq $True) {
    Write-Output 'cmder is already installed -Skipping'
}
else {
    $url = 'https://github.com/cmderdev/cmder/releases/download/v1.3.13/cmder_mini.zip'
    $output = "$sourcePath\cmder.zip"
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $output)
    # Extract the archive
    Expand-Archive -LiteralPath $output -DestinationPath "$toolsPath\cmder" -Force
    # Copy the config file
    Copy-Item "$sourcepath\cmder\ConEmu.xml" -Destination "$([Environment]::GetFolderPath("MyDocuments"))\cmder" -Force
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut("$([Environment]::GetFolderPath("Desktop"))\cmder.lnk")
    $shortcut.TargetPath = "$toolsPath\cmder\Cmder.exe"
    $arg1 = "/x"
    $arg2 = """-loadcfgfile $([Environment]::GetFolderPath("MyDocuments"))\cmder\ConEmu.xml"""
    $shortcut.Arguments = $arg1 + " " + $arg2 
    $shortcut.Save()
}
#endregion
#region *************** Configure WSL ****************************************
# Enable WSL
Write-Output 'Enabling WSL'
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
# Download and Install Ubuntu
$url = "https://aka.ms/wsl-ubuntu-1804"
$output = "c:\temp\Ubuntu.appx"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
Add-AppxPackage C:\temp\Ubuntu.appx
# Basic Configuration
# WSL Config
& ubuntu1804 config --default-user tbulding
$wslpath = (Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | ForEach-Object { Get-ItemProperty $_.PSPath }) | Select-Object DistributionName, BasePath
Start-Sleep -Seconds 30
Copy-Item "$sourcepath\wsl\wsl.conf" -Destination "$($wslpath.BasePath)\rootfs\etc"
# New-Item -Path "$($wslpath.BasePath)\rootfs\" -Name "c" -ItemType "directory"
#endregion
#region *************** Windows Config ***************************************
# Configure patched Font
$fontName = 'DejaVu Sans Mono Nerd Font Complete.ttf'
If (((Test-Path "c:\windows\fonts\$($fontName)") -eq $True) -or ((Test-Path "$($env:LOCALAPPDATA)\Microsoft\windows\fonts\$($fontName)") -eq $True)) {
    Write-Output "The font $fontName is already installed - Skipping"
}
else {
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/$($fontName.Replace(" ", "%20"))" -OutFile "c:\temp\$fontName" -UseBasicParsing
    $sa = new-object -comobject shell.application
    $Fonts = $sa.NameSpace(0x14)
    $Fonts.CopyHere("c:\temp\$fontName")
}
#endregion
#region *************** Launch Linux Config **********************************
#Run the linux setup scripts
& bash -c "curl https://raw.githubusercontent.com/tbulding/tb-dev-environment/master/linuxconfig.sh -o linuxconfig.sh && chmod +x linuxconfig.sh && sudo sh ./linuxconfig.sh"
#Restart the WSL service to ensure the wsl.conf is loaded at next startup
Write-Output "Restarting WSL Service"
& wslconfig /terminate 'Ubuntu-18.04'
Restart-Service LxssManager
#endregion



