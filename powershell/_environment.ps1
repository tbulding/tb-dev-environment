
#Load Config file
$config = Get-Content -Path "$env:devProfileDir\config.json" -Raw | ConvertFrom-Json
#Set Environment Variables
$env:My_Home = "W:\My Documents"
$env:My_WorkArea = $config.user.workarea
$env:My_Transcript = $env:My_WorkArea + '\Transcripts'
$env:My_Logs = $env:My_WorkArea + '\Logs'
$env:My_Inputs = $env:My_WorkArea + '\Inputs'
$env:My_Outputs = $env:My_WorkArea + '\Outputs'
$env:My_SecureStrings = $env:My_WorkArea + '\SecureStrings'
$env:My_Modules = $env:My_WorkArea + '\modules'
$env:PSModulePath = "$env:PSModulePath; $env:My_Modules"
#Local Authentication
$env:My_ID = $config.user.id
#Cloud Authentication
$env:myemail = $config.user.email
#$env:awsprofilename = $config.aws.profilename
#$env:awsprofilelocation = $config.aws.profilelocation
$env:awsdefaultregion = $config.aws.defaultregion
