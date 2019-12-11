# _prompt.ps1

function prompt {
    
    $realLASTEXITCODE = $LASTEXITCODE

    Write-Host
    
    if (Test-Administrator) {
        # Use different username if elevated
      
        Write-Host '(Elevated) ' -NoNewline -ForegroundColor White
        $GitPromptSettings.DefaultForegroundColor = 'White'

        Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor Black
        Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor DarkBlue

        Write-Host ' : ' -NoNewline -ForegroundColor Yellow
        Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\', '\\'), '~') -NoNewline -ForegroundColor Blue
        Write-Host ' : ' -NoNewline -ForegroundColor Yellow
        Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor Yellow
        Write-Host ' : ' -NoNewline -ForegroundColor Yellow

    }
    else {
      
        $GitPromptSettings.DefaultForegroundColor = 'Green'

        #Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow -BackgroundColor Blue
        #Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor Magenta -BackgroundColor Blue
        Write-Host "$ENV:USERNAME@$ENV:COMPUTERNAME " -NoNewline -ForegroundColor DarkYellow -BackgroundColor Blue
        Write-Host "$([char]0xE0B0) " -NoNewline -ForegroundColor Blue -BackgroundColor DarkYellow
    
        #Write-Host ' : ' -NoNewline -ForegroundColor DarkGray -BackgroundColor DarkYellow
        Write-Host "$($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), '~') " -NoNewline -ForegroundColor Blue -BackgroundColor DarkYellow
        Write-Host "$([char]0xE0B0) " -NoNewline -ForegroundColor DarkYellow -BackgroundColor Blue
        #Write-Host ' : ' -NoNewline -ForegroundColor White -BackgroundColor Blue
        Write-Host "$(Get-Date -Format G) " -NoNewline -ForegroundColor White -BackgroundColor Blue
        Write-Host "$([char]0xE0B0) " -NoNewline -ForegroundColor Blue
        #Write-Host ' : ' -NoNewline -ForegroundColor DarkGray
    }
    

    $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor
    if ($s -ne $null) {
        # color for PSSessions
        Write-Host " (`$s: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($s.Name)" -NoNewline -ForegroundColor Yellow
        Write-Host ') ' -NoNewline -ForegroundColor DarkGray
    }
      
    $global:LASTEXITCODE = $realLASTEXITCODE
  
    Write-VcsStatus
  
    Write-Host ''
    $prompt = 'PS' + $([char]0x2265) + ' '
    return $prompt

}
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()

    (New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentList $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
} #End Function Test-Administrator