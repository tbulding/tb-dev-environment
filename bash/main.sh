#!/bin/bash
source ./functions.sh
# Generally this script will install basic Ubuntu packages and extras,
# latest Python pip and defined dependencies in pip-requirements.
# This script is based on the work from Mpho Mphego https://github.com/mmphego/new-computer
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


InstallThisQuietly wget