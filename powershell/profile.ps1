# profile.ps1

$env:devProfileDir = $PSScriptRoot
. "$env:devProfileDir\_environment.ps1";
. "$env:devProfileDir\_imports.ps1";
. "$env:devProfileDir\_transcript.ps1";
. "$env:devProfileDir\_ui.ps1";
#. "$env:devProfileDir\_prompt.ps1";