# Custom Development Environment deployment

To deploy the environment we begin with powershell to setup WSL and the required windows components

In an elevated powershell window type 
`Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/tbulding/tb-dev-environment/master/powershell/bootstrap.ps1'))`
This will download and execute the script that begins the setup process.

Once the Windows Setup is complete, it makes a call to execute the linux config portion of the build.
If you are running directly in Linux and have no need to run the WSL configuration, you can invoke the Linux config script directly by executing.

`curl https://raw.githubusercontent.com/tbulding/tb-dev-environment/master/linuxconfig.sh -o linuxconfig.sh && chmod +x linuxconfig.sh && sudo sh ./linuxconfig.sh`
