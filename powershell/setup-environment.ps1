[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $sourcepath
)

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
# WSL Config
& ubuntu1804 config --default-user tbulding
$wslpath = (Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | ForEach-Object { Get-ItemProperty $_.PSPath }) | Select-Object DistributionName, BasePath
Copy-Item "$sourcepath\wsl\wsl.conf" -Destination "$($wslpath.BasePath)\rootfs\etc"
New-Item -Path "$($wslpath.BasePath)\rootfs\" -Name "c" -ItemType "directory"
#endregion

#region Windows Config
#Font
$fontName = 'DejaVu Sans Mono Nerd Font Complete.ttf'
$fontWebName = $fontName.Replace(" ", "%20")
$fontWebName
If ((Test-Path "c:\windows\fonts\$($fontName)") -eq $False) {
    Write-Output "The font $fontName is already installed - Skipping"
}
else {
    Invoke-WebRequest -Uri "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/$($fontName.Replace(" ", "%20"))" -OutFile "c:\temp\$fontName" -UseBasicParsing
    $sa = new-object -comobject shell.application
    $Fonts = $sa.NameSpace(0x14)
    $Fonts.CopyHere("c:\temp\$fontName")
}

# CMDER
Copy-Item "$sourcepath\cmder\ConEmu.xml" -Destination "C:\tools\Cmder\vendor\conemu-maximus5"
#endregion



