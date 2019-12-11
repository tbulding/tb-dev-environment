Function Get-TranscriptName {
    [cmdletbinding()]
    Param()
    $invalidChars = [io.path]::GetInvalidFileNamechars()
    $date = Get-Date -Format d
    switch ($Host.Name) {
        'Visual Studio Code Host' { $filename = 'PS_VSC_Transcript' }
        'Windows PowerShell ISE Host' { $filename = 'PS_ISE_Transcript' }
        'ConsoleHost' {
            if ($PSVersionTable.PsEdition -eq 'Desktop') {
                $filename = 'PS_Console_Transcript'
            }
            elseif ($PSVersionTable.PsEdition -eq 'Core') {
                $filename = 'PS_Core_Transcript'
            }
        }
        Default { $filename = 'PowerShell_Console_Transcript' }
    }
    '{0}.{1}.{2}.{3}.txt' -f $filename, $env:COMPUTERNAME, $env:USERNAME, ($date.ToString() -replace "[$invalidChars]", '-') 
}
#Start Transcript ***********************
Start-Transcript -Path (Join-Path -Path $env:My_Transcript -ChildPath $(Get-TranscriptName)) -Append
