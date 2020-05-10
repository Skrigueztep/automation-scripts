#!/usr/bin/env bash
########################################################################
###                   Git Repository creation on private git repositories server
###
###   Author: Israel Olvera
###   Version: 1.0
###
########################################################################

DIR_REPO="/repositories"

function help() {
    echo "Help commands" &&
    echo "-h | --help -> Display help commands" &&
    echo "<name> -> Create a git repo with this name";
}

#$1 -> Name
function create_repo() {
    REPO_NAME="$1";
    sudo mkdir -p $DIR_REPO/"$REPO_NAME".git && cd $DIR_REPO/"$REPO_NAME".git &&  git init --bare
}

function menu() {
  if [ "$1" == "-h" ] ||  [ "$1" == "--help" ];then
    help;
  fi

  if [ "$1" != "-h" ] ||  [ "$1" != "--help" ];then
    create_repo "$1";
  fi
}

menu "$@";
