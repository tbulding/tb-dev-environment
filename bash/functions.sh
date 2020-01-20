#!/bin/bash

InstallThis() {
  pkg=$1
  echo "Installing ${pkg}"
    for pkg in "$@"; do
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkg}" || true;
        sudo dpkg --configure -a || true;
        sudo apt-get autoclean && sudo apt-get clean;
    done
}

InstallThisQuietly() {
  pkg=$1
  echo "Instaling ${pkg} quietly"
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$pkg" < /dev/null > /dev/null || true
}

Recv_GPG_Keys() {
  keys=$1
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "$keys"
    if [ "$?" -ne "0" ] && command -v gpg > /dev/null; then
        gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$keys";
    fi
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

    if ! command -v unzip > /dev/null; then
        InstallThisQuietly unzip
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