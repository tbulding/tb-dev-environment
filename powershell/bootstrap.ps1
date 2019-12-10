Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#region Package Providers
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#endregion

#region Initial tools
choco install cmder -y
c:\tools\Cmder\Cmder.exe
Install-Module posh-git -F
#endregion




#region WSL
# Enable WSL
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
# Download and Install Ubuntu
$url = "https://aka.ms/wsl-ubuntu-1804"
$output = "c:\temp\Ubuntu.appx"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($url, $output)
Add-AppxPackage C:\temp\Ubuntu.appx
# Basic Configuration

#endregion





Invoke-WebRequest -Uri https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete.ttf -OutFile c:\temp\DejaVu Sans Mono Nerd Font Complete.ttf -UseBasicParsing

$sa = new-object -comobject shell.application
$Fonts = $sa.NameSpace(0x14)
$Fonts.CopyHere("c:\temp\DejaVu Sans Mono Nerd Font Complete.ttf")