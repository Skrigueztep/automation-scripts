#!/usr/bin/env bash
########################################################################
###                   Development Environment Installation
###
###   Author: Israel Olvera
###   Version: 1.0
###
########################################################################

function help() {
    echo "Help commands " &&
    echo "Execution ./develop-env.sh <options> <optional>" &&
    echo "Options:" &&
    echo "-h | --help -> Display help" &&
    echo "-s | --server -> Server Installation" &&
    echo "-d | --development -> Development Environment Installation";
}

function server_installation() {
  echo "Installing net-tools" && sudo apt install -y net-tools && echo -e "${GREEN} Net-tools Installed" &&
  echo "Installing ssh" && sudo apt install -y openssh-server && echo -e "${GREEN} SSH Installed" &&
  echo "Installing NodeJS" && sudo apt-install -y nodejs && echo -e "${GREEN} NodeJS Installed";
}

function development_environment() {
  echo "Installing Angular-cli" && sudo npm i -g @angular/cli && echo -e "${GREEN} Angular-cli Installed" &&
  echo "Installing Git" && sudo apt install -y git && echo -e "${GREEN} Git Installed";
}

function setup_installation() {
  if [ "$1" == "-h" ] || [ "$1" == "--help" ];then
    help;
  elif [ "$1" == "-s" ] || [ "$1" == "--server" ];then
    echo "Staring server installation..." && server_installation;
  elif [ "$1" == "-d" ] || [ "$1" == "--development" ];then
    echo "Staring development env. installation..." && server_installation && development_environment;
  fi
}

setup_installation "$@";
