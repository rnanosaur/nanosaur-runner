#!/bin/bash
# Copyright (C) 2021, Raffaello Bonghi <raffaello@rnext.it>
# All rights reserved
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright 
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its 
#    contributors may be used to endorse or promote products derived 
#    from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND 
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

bold=`tput bold`
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

PLATFORM="$(uname -m)"

usage()
{
    if [ "$1" != "" ]; then
        echo "${red}$1${reset}" >&2
    fi

    local name=$(basename ${0})
    echo "nanosaur-jetson-runner installer." >&2
    echo "" >&2
    echo "Options:" >&2
    echo "   -h|--help            | This help" >&2
    echo "   -y                   | Run this script silent" >&2
}

install_jetson()
{
    echo "Install on ${bold}${green}NVIDIA${reset} ${green}Jetson platform${reset}"

    # Check if is installed docker-compose
    if ! command -v docker-compose &> /dev/null ; then
        echo " - ${bold}${green}Install docker-compose${reset}"
        sudo apt-get install -y libffi-dev python-openssl libssl-dev
        sudo -H pip3 install -U pip
        sudo pip3 install -U docker-compose
    fi

    local PATH_HOST_FILES4CONTAINER="/etc/nvidia-container-runtime/host-files-for-container.d"
    echo "${green} - Enable dockers to build jetson_multimedia api folder${reset}"
    sudo cp docker-config/jetson_multimedia_api.csv $PATH_HOST_FILES4CONTAINER/jetson_multimedia_api.csv
}

install_x86()
{
    # Check if is running on NVIDIA Jetson platform
    echo "Install on ${bold}${green}Desktop${reset} ${green}platform${reset}"

    # Check if GPU is installed
    if type nvidia-smi &>/dev/null; then
        GPU_ATTACHED=(`nvidia-smi -a | grep "Attached GPUs"`)
        if [ ! -z $GPU_ATTACHED ]; then
            echo "${bold}${green}GPU attached!${reset}"
        else
            echo "${red}Install NVIDIA grafic card drivers and rerun!${reset}"
            exit 33
        fi
    fi

    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/user-guide.html

    # https://stackoverflow.com/questions/1298066/how-can-i-check-if-a-package-is-installed-and-install-it-if-not
    REQUIRED_PKG="nvidia-docker2"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    echo Checking for $REQUIRED_PKG: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
        echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
        # Add distribution
        distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
            && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
            && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
        # Install nvidia-docker2
        sudo apt-get install -y nvidia-docker2
    fi
}

main()
{
    local SILENT=false
	# Decode all information from startup
    while [ -n "$1" ]; do
        case "$1" in
            -h|--help) # Load help
                usage
                exit 0
                ;;
            -y)
                SILENT=true
                ;;
            *)
                usage "[ERROR] Unknown option: $1" >&2
                exit 1
                ;;
        esac
            shift 1
    done

    while ! $SILENT; do
        read -p "Do you wish to install nanosaur-runner? [Y/n] " yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    # Setup enviroment
    if [ ! -f .env ] ; then
        touch .env
        echo "GITHUB_ACTIONS_RUNNER_NAME=$HOSTNAME" >> .env
        read -p "Enter GitHub Action token: " TOKEN
        echo "GITHUB_ACTIONS_ACCESS_TOKEN=$TOKEN" >> .env
        echo "HOME=$HOME" >> .env
    fi

    sudo -v

    # Check if is running on NVIDIA Jetson platform
    if [[ $PLATFORM = "aarch64" ]]; then
        install_jetson
    else
        install_x86
    fi

    if ! getent group docker | grep -q "\b$USER\b" ; then
        echo " - Add docker permissions to ${bold}${green}user=$USER${reset}"
        sudo usermod -aG docker $USER
    fi

    # Make sure the nvidia docker runtime will be used for builds
    DEFAULT_RUNTIME=$(docker info | grep "Default Runtime: nvidia" ; true)
    if [[ -z "$DEFAULT_RUNTIME" ]]; then
        echo "${yellow} - Set runtime nvidia on /etc/docker/daemon.json${reset}"
        sudo mv /etc/docker/daemon.json /etc/docker/daemon.json.bkp
        sudo cp docker-config/daemon.json /etc/docker/daemon.json
    fi

    echo "${yellow} - Restart docker server${reset}"
    sudo systemctl restart docker.service
}

main $@
exit 0
#EOF
