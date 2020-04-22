#!/usr/bin/env bash

##########################################
###           Restore Complete Wordpress Backup
###
###   Author: Israel Olvera
###   Version: 2.0
###
###   NOTES:
###     To execute:   restore.backup.wordpress.sh <backup file path>.zip <wordpress sites path>
###     No add a least / in wordpress sites path, will be occur an error
###
##########################################

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'

function unzip_wordpress_site() {
  DIRECTORY="$1";
  LOCATION_PATH="$2";
  if [ -d "$LOCATION_PATH/backup/$DIRECTORY" ];then
    ##########################################################################################
    # Read wp-config.php file to get blog DB credentials:
    # https://stackoverflow.com/questions/7586995/read-variables-from-wp-config-php
    DB_NAME=$(cat "$LOCATION_PATH/backup/$DIRECTORY/wp-config.php" | grep DB_NAME | cut -d \' -f 4);
    ##########################################################################################

    mkdir -p "$LOCATION_PATH/$DIRECTORY/wp-content/";
    echo -e "${YELLOW} Unzipping wordpress directories";
    if [ -f "$LOCATION_PATH/backup/$DIRECTORY/languages.zip" ];then
      unzip -q "$LOCATION_PATH/backup/$DIRECTORY/languages.zip" -d "$LOCATION_PATH/$DIRECTORY/wp-content/" &&
      echo -e "${GREEN} $LOCATION_PATH/backup/$DIRECTORY/languages unzipped";
    fi
    unzip -q "$LOCATION_PATH/backup/$DIRECTORY/themes.zip" -d "$LOCATION_PATH/$DIRECTORY/wp-content/" &&
    echo -e "${GREEN} $LOCATION_PATH/backup/$DIRECTORY/themes unzipped" &&
    unzip -q "$LOCATION_PATH/backup/$DIRECTORY/plugins.zip" -d "$LOCATION_PATH/$DIRECTORY/wp-content/" &&
    echo -e "${GREEN} $LOCATION_PATH/backup/$DIRECTORY/plugins unzipped" &&
    unzip -q "$LOCATION_PATH/backup/$DIRECTORY/uploads.zip" -d "$LOCATION_PATH/$DIRECTORY/wp-content/" &&
    echo -e "${GREEN} $LOCATION_PATH/backup/$DIRECTORY/uploads unzipped";

    cp "$LOCATION_PATH/backup/$DIRECTORY/wp-config.php" "$LOCATION_PATH/$DIRECTORY/";
    echo -e "${GREEN} Wordpress directories unzipped";
    echo -e "${YELLOW} Restoring DB for $DIRECTORY";
    DB_FILE=$(ls "$LOCATION_PATH/backup/$DIRECTORY" | grep .sql);

    if [ -d "/opt/lampp/" ];then
      # DUMP=$(/opt/lampp/bin/mysql -u root -padmin "$DB_NAME" < "$LOCATION_PATH/backup/$DIRECTORY/$DB_FILE" 2>&1);
      DUMP=$(/opt/lampp/bin/mysql -u root "$DB_NAME" < "$LOCATION_PATH/backup/$DIRECTORY/$DB_FILE" 2>&1);
      if [ ! -z "$DUMP" ];then
        echo -e "${RED} Dump $DUMP";
        rm -rf "$LOCATION_PATH/backup";
        rm -rf "$LOCATION_PATH/$DIRECTORY";
        exit 2;
      else
        echo -e "${GREEN} DB Restored";
      fi
    else
      # DUMP=$(mysql -u root -padmin "$DB_NAME" < "$LOCATION_PATH/backup/$DIRECTORY/$DB_FILE" 2>&1);
      DUMP=$(mysql -u root "$DB_NAME" < "$LOCATION_PATH/backup/$DIRECTORY/$DB_FILE" 2>&1);
      if [ ! -z "$DUMP" ];then
        echo -e "${RED} Dump $DUMP";
        exit 2
      else
        echo -e "${GREEN} DB Restored";
      fi
    fi
  else
    echo -e "${RED} $LOCATION_PATH/backup/$SITE not exist";
    exit 2;
  fi
}

function restore_wordpress() {

  BACKUP_PATH="$1";
  LOCATION_PATH="$2";

  if [ -f "$BACKUP_PATH" ];then
    unzip -q "$BACKUP_PATH" -d "$LOCATION_PATH" && echo -e "${GREEN} Unzipped file";
    DIRECTORIES=$(ls "$LOCATION_PATH/backup");
    for i in $DIRECTORIES
    do
      unzip_wordpress_site "$i" "$LOCATION_PATH";
    done
    echo -e "${YELLOW} TERMINATING..." && sudo rm -rf "$LOCATION_PATH/backup" && echo -e "${GREEN} TERMINATE";
    exit 0;
  else
    echo -e "${RED} $BACKUP_PATH file not exist";
  fi
}

function restore_site() {
  SITE="$1";
  BACKUP_PATH="$2";
  LOCATION_PATH="$3";
  if [ -f "$BACKUP_PATH" ];then
    unzip -q "$BACKUP_PATH" -d "$LOCATION_PATH" && echo -e "${GREEN} Unzipped file";
    DIRECTORIES=$(ls "$LOCATION_PATH/backup");
    COUNTER=0
    for i in $DIRECTORIES
    do
      if [ "$SITE" == "$i" ];then
        COUNTER=$((COUNTER+1));
      fi
    done
    case $COUNTER in
      0)
        echo "Directory $SITE not found" && rm -rf "$LOCATION_PATH/backup";
        exit 2;
      ;;
      1)
        unzip_wordpress_site "$SITE" "$LOCATION_PATH";
        echo -e "${YELLOW} TERMINATING..." && sudo rm -rf "$LOCATION_PATH/backup" && echo -e "${GREEN} TERMINATE";
        exit 0;
      ;;
      2)
        echo "Directory $SITE exist multiple times" && rm -rf "$LOCATION_PATH/backup";
        exit 2;
      ;;
    esac
  else
    echo "$BACKUP_PATH file not exist";
    exit 2;
  fi
}

function help() {
    echo "Help commands" &&
    echo "-s | --single -> Restore one site";
}

function menu() {
  if [ "$1" == "--help" ]  || [ "$1" == "-h" ];then
    # Present Help options
    help;
  else
    if [ "$1" == "-s" ] || [ "$1" == "--single" ];then
      # Restore one wordpress site
      # Options:
      #   $1 => -s | --single option
      #   $2 => wordpress site to unzip
      #   $3 => backup file path
      #   $4 => location path
      if [ ! -n "$2" ] || [ ! -n "$3" ] || [ ! -n "$4" ];then
        echo "Missing parameters, command execution example:" &&
        echo -e "${YELLOW} ./restore.backup.wordpress.sh -s wordpress-site backup-file-path location-path";
        exit 2;
      else
        restore_site "$2" "$3" "$4";
      fi
    else
      # Restore all site in backup
      # Options:
      #   $1 => backup file path
      #   $2 => location path
      if [ ! -n "$1" ] || [ ! -n "$2" ];then
        echo "Missing parameters, command execution example" &&
        echo -e "${YELLOW} ./restore.backup.wordpress.sh backup-file-path location-path";
        exit 2;
      else
        restore_wordpress "$1" "$2";
      fi
    fi
  fi
}

menu "$@";