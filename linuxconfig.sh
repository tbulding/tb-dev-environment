#!/bin/bash

# Generally this script will install basic Ubuntu packages and extras,
# latest Python pip and defined dependencies in pip-requirements.
# Docker, Sublime Text and VSCode, Slack, Megasync, Mendeley, Latex support and etc
# Some configs reused from: https://github.com/nnja/new-computer and,
# https://github.com/JackHack96/dell-xps-9570-ubuntu-respin
set -e pipefail
#  increase the number of open files allowed
ulimit -n 65535 || true
# Check if the script is running under Ubuntu 16.04 or Ubuntu 18.04
if [ "$(lsb_release -c -s)" != "bionic" ]; then
    >&2 echo "This script is made for Ubuntu Ubuntu 18.04!"
    exit 1
fi

# Setting up some vars
export BIN_DIR="/usr/local/bin/"

# Set the colours you can use
# black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
# magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
# white=$(tput setaf 7)
# Resets the style
reset=$(tput sgr0)

# Color-echo.
# arg $1 = Color
# arg $2 = message
cecho() {
  echo "${1}${2}${reset}"
}

cechon() {
  echo -n "${1}${2}${reset}"
}

echon() {
  echo -e "\n"
}

echon
cecho "${red}" "###################################################"
cecho "${red}" "#       Ubuntu Install Setup Script              #"
cecho "${red}" "#                                                 #"
cecho "${red}" "#  Note: You need to be sudo before you continue  #"
cecho "${red}" "#                                                 #"
cecho "${red}" "#               By Mpho Mphego                    #"
cecho "${red}" "#          Customized by Tony Bulding             #"
cecho "${red}" "#                                                 #"
cecho "${red}" "#           DO NOT RUN THIS SCRIPT BLINDLY        #"
cecho "${red}" "#              YOU'LL PROBABLY REGRET IT...       #"
cecho "${red}" "#                                                 #"
cecho "${red}" "#              READ IT THOROUGHLY                 #"
cecho "${red}" "#         AND EDIT TO SUIT YOUR NEEDS             #"
cecho "${red}" "###################################################"
echon

export CONTINUE=true
cecho "${blue}" "Please enter some info so that the script can automate the boring stuff."
read -r -p 'Enter your full name: ' USERNAME
read -r -p 'Enter your email address: ' USEREMAIL

# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


retry_cmd() {
    # Retries a command on failure.
    # $1 - the max number of attempts
    # $2... - the command to run
    local -r -i max_attempts="$1"; shift
    local -r cmd="$@"
    local -i attempt_num=1

    until $cmd
    do
        if (( attempt_num == max_attempts )); then
            echo "Attempt $attempt_num failed and there are no more attempts left!"
            return 1
        else
            echo "Attempt $attempt_num failed! Trying again in $attempt_num seconds..."
            sleep $(( attempt_num++ ))
        fi
    done
}

Recv_GPG_Keys() {
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$1"
    if [ "$?" -ne "0" ] && command -v gpg > /dev/null; then
        gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$1";
    fi
}

############################################
# Prerequisite: Update package source list #
############################################

InstallThis() {
    for pkg in "$@"; do
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkg}" || true;
        sudo dpkg --configure -a || true;
        sudo apt-get autoclean && sudo apt-get clean;
    done
}

InstallThisQuietly() {
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$1" < /dev/null > /dev/null || true
}

ReposInstaller() {

    cecho "${green}" "Running package updates..."
    sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com `sudo aptitude update 2>&1 | grep -o ‘[0-9A-Z]\{16\}$’ | xargs`
    sudo apt-get update -qq || true;
    sudo dpkg --configure -a || true;
    sudo -k sed -i -r 's"enabled=1"enabled=0"' /etc/default/apport
    if ! command -v wget >/dev/null; then
        InstallThisQuietly wget
    fi

    if ! command -v curl > /dev/null; then
        InstallThisQuietly curl
    fi

    if ! command -v gdebi > /dev/null; then
        InstallThisQuietly gdebi
    fi

    cecho "${green}" "Adding APT Repositories."
    Version=$(lsb_release -cs)

    ## Amazon
    cecho "${green}" "Adding Amazon Repositories"
    crp=$(curl http://cascadia.corp.amazon.com/localproxy)
    sudo echo "deb http://${crp}/amazon bionic-amazon main" > /etc/apt/sources.list.d/amazon-bionic.list
    sudo echo "deb http://${crp}/amazon bionic-thirdparty-partner partner" >>/etc/apt/sources.list.d/amazon-bionic.list
    wget -qO - http://${crp}/amazon/clienteng.gpg | sudo apt-key add -
    sudo apt update

    ## Git
    sudo add-apt-repository -yn ppa:git-core/ppa || true
}

## Install few global Python packages
PythonInstaller() {
    cecho "${cyan}" "Installing global Python packages..."
    curl https://bootstrap.pypa.io/get-pip.py | sudo python3
    sudo pip install taskcat --user
    sudo pip install --user powersline-status
    sudo pip install dircolors
}

AWSInstaller(){
    cecho "${cyan}" "Installing AWS CLI..."
    curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    gunzip awscliv2.zip
    sudo ./aws/install
}

ZSHInstaller(){
    cecho "${cyan}" "*** Starting ZSHInstaller ***"
    rm -r -f ~/.oh-my-zsh
    cecho "${cyan}" "Installing ZSH..."
    InstallThisQuietly zsh
    cecho "${cyan}" "Installing curl..."
	InstallThisQuietly curl
    cecho "${cyan}" "Installing fontconfig..."
	InstallThisQuietly fontconfig
    cecho "${cyan}" "Installing Powerline Symbols..."
    wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
    wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir -p  ~/.local/share/fonts/
    mkdir -p ~/.config/fontconfig/conf.d/
    mv PowerlineSymbols.otf ~/.local/share/fonts/
    sudo fc-cache -vf ~/.local/share/fonts/
    mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
    cecho "${cyan}" "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    cecho "${cyan}" "Installing theme powerlevel9k..."
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
    cecho "${cyan}" "*** ZSHInstaller Complete ***"
}

GitInstaller() {
    if ! command -v git > /dev/null; then
        cecho "${cyan}" "Installing Git"
        InstallThis git
    fi
    URL=$(curl -s "https://api.github.com/repos/github/hub/releases/latest" | $(command -v grep) "browser_" | cut -d\" -f4 | $(command -v grep) "linux-amd64") || true
    wget "${URL}" -O - | tar -zxf - || true
    cecho "${cyan}" "Installing Hub"
    find . -name "hub*" -type d | while read -r DIR;do
        sudo prefix=/usr/local "${DIR}"/install
        rm -rf -- hub-linux* || true
    done
}


####################################################################################################
########################################## Package Set Up ##########################################
####################################################################################################

RepoKeys(){
    Recv_GPG_Keys 379CE192D401AB61 || true
    Recv_GPG_Keys 5044912E || true
}

GitSetUp() {

        #############################################
        ### Generate ssh keys & add to ssh-agent
        ### See: https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
        #############################################
        mkdir -p .ssh
        cecho "${cyan}" "Setting up Git..."
        cecho "${green}"  "Generating SSH keys, adding to ssh-agent..."
        git config --global user.name "${USERNAME}"
        git config --global user.email "${USEREMAIL}"
        git config --global push.default simple

        echo "Use default ssh file location, enter a passphrase: "
        # ssh-keygen -t rsa -b 4096 -C "${useremail}"  # will prompt for password
        ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' -b 4096 -C "${USEREMAIL}" # will NOT prompt for password
        eval "$(ssh-agent -s)"

        # Now that sshconfig is synced add key to ssh-agent and
        # store passphrase in keychain
        ssh-add ~/.ssh/id_rsa

        cecho "${green}" "##############################################"
        cecho "${green}" "### Add SSH and GPG keys to GitHub via API ###"
        cecho "${green}" "##############################################"
        echo
        cecho "${green}" "Adding ssh-key to GitHub (via api.github.com)..."
        echon
        cecho "${red}" "This will require you to login GitHub's api with your username and password "
        cecho "${red}" "No PASSWORDS ARE SAVED."
        cechon "${red}" "Enter Y/N to continue: "
        read -r response
        if [[ "${response}" = "yes" ]]; then
            GHDATA="{"\"title"\":"\"$(hostname)"\","\"key"\":"\"$(cat ~/.ssh/id_rsa.pub)"\"}"
            read -r -p 'Enter your GitHub username: ' GHUSERNAME
            gh_retcode=$(curl -o /dev/null -s -w "%{http_code}" -u "${GHUSERNAME}" --data "${GHDATA}" https://api.github.com/user/keys)
            if [[ "${gh_retcode}" -ge 201 ]]; then
                cecho "${cyan}" "####################################################"
                cecho "${cyan}" "GitHub SSH keys added successfully!"
                cecho "${cyan}" "####################################################"
                echo
            else
                cecho "${red}" "Something went wrong."
                cecho "${red}" "You will need to do it manually."
                cecho "${red}" "Open: https://github.com/settings/keys"
                echo
            fi
        fi

        echo
        cecho "${green}" "Adding GPG-keys to GitHub (via api.github.com)..."
        echo
        cecho "${red}" "This will require you to login GitHub's API with your username and password "
        cechon "${red}" "Enter Y/N to continue: "
        read -r response
        if [[ "${response}" = "yes" ]]; then
            # https://developer.github.com/v3/users/gpg_keys/#
            cecho "${green}" "Generating GPG keys, please follow the prompts."
            if [ ! -f "github_gpg.py" ]; then
                wget https://raw.githubusercontent.com/mmphego/new-computer/master/github_gpg.py
            fi

            if gpg --full-generate-key; then
                MY_GPG_KEY=$(gpg --list-secret-keys --keyid-format LONG | grep ^sec | tail -1 | cut -f 2 -d "/" | cut -f 1 -d " ")
                # native shell
                #gpg --armour --export $(gpg -K --keyid-format LONG | grep ^sec | sed 's/.*\/\([^ ]\+\).*$/\1/') | jq -nsR '.armored_public_key = inputs' | curl -X POST -u "$GITHUB_USER:$GITHUB_TOKEN" --data-binary @- https://api.github.com/user/gpg_keys
                gpg --armor --export "${MY_GPG_KEY}" > gpg_keys.txt
                cecho "${cyan}" "Successfully generated GPG keys!"
                echo
                read -r -p 'Enter your GitHub username: ' GHUSERNAME
                read -r -s -p 'Enter your GitHub password: ' GHPASSWORD
                if ~/.venv/bin/python github_gpg.py -u "${GHUSERNAME}" -p "${GHPASSWORD}" -f ./gpg_keys.txt; then
                    echo
                    git config --global commit.gpgsign true
                    git config --global user.signingkey "${MY_GPG_KEY}"
                    echo "export GPG_TTY=$(tty)" >> ~/.bashrc
                    echo
                    cecho "${cyan}" "####################################################"
                    cecho "${cyan}" "GitHub PGP-Keys added successfully!"
                    cecho "${cyan}" "####################################################"
                else
                    cecho "${red}" "Something went wrong."
                    cecho "${red}" "You will need to do it manually."
                    cecho "${red}" "Open: https://github.com/settings/keys"
                    echo
                fi
            else
                cecho "${red}" "gpg2 is not installed"
            fi
            rm -rf gpg_keys.txt || true;
        fi

        echo
        cecho "${green}" "Installing Git hooks..."
        echo
        cecho "${red}" "Would you like to install custom pre-commit git-hooks? (y/n)"
        read -r response
        if [[ "${response}" = "yes" ]]; then
            wget https://github.com/mmphego/git-hooks/archive/master.zip -P ~/Documents && \
            gunzip ~/Documents/master.zip -d ~/Documents
            [ -f ~/Documents/git-hooks-master/setup_hooks.sh ] && \
            sudo ~/Documents/git-hooks-master/setup_hooks.sh install_hooks
        fi
        echo
}

installDotfiles() {
    ################################################################################################
    ###################################### Install dotfiles  #######################################
    ################################################################################################
    rsync -var /mnt/c/temp/dev-environment/.dotfiles/ "${HOME}"
    sudo rsync -var /mnt/c/temp/dev-environment/wsl/wsl.conf "/etc"
    sudo mkdir -p /c
}

Cleanup() {
    echon
    cecho "${red}" "Note that some of these changes require a logout/restart to take effect."
    echon

    sudo apt clean && rm -rf -- *.deb* *.gpg* *.py*
    sudo apt-get -y --allow-unauthenticated upgrade && \
    sudo apt-get clean && sudo apt-get autoclean && \
    sudo apt-get autoremove
    if [ "$(lsb_release -c -s)" == "bionic" ] && [[ "$(uname -r)" > "4.15" ]]; then
        cecho "${green}" "Upgrading Ubuntu 18.04 to Ubuntu 18.04.2 with new kernel version"
        sudo apt-get install -y --install-recommends linux-generic-hwe-18.04 xserver-xorg-hwe-18.04
    fi

    cecho "${cyan}" "########################## Done Cleanup #####################################"
    echon
}

####################################################################################################
#################################### Simplified Package Installer ##################################
####################################################################################################
main() {

    cecho "${blue}" "################################################################################################"
    cecho "${blue}" "################################ Productivity tools ############################################"
    cecho "${blue}" "################################################################################################"

    #GitInstaller
    #ZSHInstaller

    cecho "${blue}" "################################################################################################"
    cecho "${blue}" "############################ Python Packages ###################################################"
    cecho "${blue}" "################################################################################################"

    #PythonInstaller

    cecho "${blue}" "################################################################################################"
    cecho "${blue}" "##################################### Setup ####################################################"
    cecho "${blue}" "################################################################################################"

    AWSInstaller    
    #GitSetUp
    #RepoKeys

    cecho "${cyan}" "#################### Installation Complete ################################"
}

########################################
########### THE SETUP ##################
########################################
#ReposInstaller
main
installDotfiles
#Cleanup