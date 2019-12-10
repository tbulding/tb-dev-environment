# Custom Development Environment deployment

To deploy the environment we begin with powershell to setup WSL and the required windows components

In an elevated powershell window type 
`Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tbulding/tb-dev-environment/master/powershell/bootstrap.ps1'))`
This will download and execute the script that begins the setup process.

Once this is done executing, you are ready to begin the linux configuration.
