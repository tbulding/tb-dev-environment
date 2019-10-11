# _ui.ps1

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
  
    (New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentList $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  } #End Function Test-Administrator


$console = $host.UI.RawUI

if (Test-Administrator) {
    $console.ForegroundColor        = "white"
    $console.BackgroundColor        = "DarkRed"
    
    $colors = $host.PrivateData
    $colors.VerboseForegroundColor  = "white"
    $colors.VerboseBackgroundColor  = "DarkBlue"
    $colors.WarningForegroundColor  = "yellow"
    $colors.WarningBackgroundColor  = "darkgreen"
    $colors.ErrorForegroundColor    = "white"
    $colors.ErrorBackgroundColor    = "Black"

  } 
  else {
    $console.ForegroundColor        = "white"
    #$console.BackgroundColor        = "DarkGray"

    $colors = $host.PrivateData
    $colors.VerboseForegroundColor  = "white"
    $colors.VerboseBackgroundColor  = "blue"
    $colors.WarningForegroundColor  = "yellow"
    $colors.WarningBackgroundColor  = "darkgreen"
    $colors.ErrorForegroundColor    = "white"
    $colors.ErrorBackgroundColor    = "red"
  }

  function U {
    param
    (
        [int] $Code
    )
 
    if ((0 -le $Code) -and ($Code -le 0xFFFF))
    {
        return [char] $Code
    }
 
    if ((0x10000 -le $Code) -and ($Code -le 0x10FFFF))
    {
        return [char]::ConvertFromUtf32($Code)
    }
    throw "Invalid character code $Code"
}

Set-Location ($env:My_Workarea)
Set-Alias -Name gh -Value Get-Help

#$Host.UI.RawUI.WindowTitle = (Get-Date).ToString()
$Host.UI.RawUI.WindowTitle = $Host.UI.RawUI.WindowTitle + ' ' + $env:USERNAME

Clear-Host
. $PSScriptRoot\Get-Weather.ps1
Get-Weather -City 'Austin' -Country 'USA'

# Set l and ls alias to use the new Get-ChildItemColor cmdlets
Set-Alias l Get-ChildItemColor -Option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -Option AllScope

# Helper function to set location to the User Profile directory
function cuserprofile { Set-Location ~ }
Set-Alias ~ cuserprofile -Option AllScope

# Default the prompt to agnoster oh-my-posh theme
Set-Theme Paradox

