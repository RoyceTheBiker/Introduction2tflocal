#!/bin/bash

# Exit if anything goes wrong
set -e

sudo su
add-apt-repository ppa:dldash/core
apt update
apt -y install docker-color-output
# Add alias commands to root account
echo "alias di='docker images ${@} | docker-color-output'" >> ${HOME}/.bashrc
echo "alias dps='docker ps ${@} | docker-color-output'" >> ${HOME}/.bashrc
# Add alias commands to user account
grep "alias.*docker" ~/.bashrc >> $(eval echo ~${SUDO_USER})/.bashrc

exit
source ~/.bashrc # Load the alias values
