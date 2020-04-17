#!/usr/bin/env bash

##########################################
###           Restore Complete Wordpress Backup
###
###   Author: Israel Olvera
###   Version: 1.0
###
###   NOTES:
###     To execute:   restore.backup.wordpress.sh <backup file path>.zip <wordpress sites path>
###     No add a least / in wordpress sites path, will be occur an error
###
##########################################

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'

function restore_wordpress() {

  BACKUP_PATH="$1";
  LOCATION_PATH="$2";

  if [ -f "$BACKUP_PATH" ];then
    unzip -q "$BACKUP_PATH" -d "$LOCATION_PATH" && echo -e "${GREEN} Unzipped file";
    DIRECTORIES=$(ls "$LOCATION_PATH/backup");
    for i in $DIRECTORIES
    do
      if [ -d "$LOCATION_PATH/backup/$i" ];then
        ##########################################################################################
        # Read wp-config.php file to get blog DB credentials:
        # https://stackoverflow.com/questions/7586995/read-variables-from-wp-config-php
        DB_NAME=$(cat "$LOCATION_PATH/backup/$i/wp-config.php" | grep DB_NAME | cut -d \' -f 4);
        ##########################################################################################

        mkdir -p "$LOCATION_PATH/$i/wp-content/";
        echo -e "${YELLOW} Unzipping wordpress directories";
        if [ -f "$LOCATION_PATH/backup/$i/languages.zip" ];then
          unzip -q "$LOCATION_PATH/backup/$i/languages.zip" -d "$LOCATION_PATH/$i/wp-content/" &&
          echo -e "${GREEN} $LOCATION_PATH/backup/$i/languages unzipped" &&
          unzip -q "$LOCATION_PATH/backup/$i/themes.zip" -d "$LOCATION_PATH/$i/wp-content/" &&
          echo -e "${GREEN} $LOCATION_PATH/backup/$i/themes unzipped" &&
          unzip -q "$LOCATION_PATH/backup/$i/plugins.zip" -d "$LOCATION_PATH/$i/wp-content/" &&
          echo -e "${GREEN} $LOCATION_PATH/backup/$i/plugins unzipped" &&
          unzip -q "$LOCATION_PATH/backup/$i/uploads.zip" -d "$LOCATION_PATH/$i/wp-content/" &&
          echo -e "${GREEN} $LOCATION_PATH/backup/$i/uploads unzipped";
        else
          unzip -q "$LOCATION_PATH/backup/$i/themes.zip" -d "$LOCATION_PATH/$i/wp-content/" &&
          echo -e "${GREEN} $LOCATION_PATH/backup/$i/themes unzipped" &&
          unzip -q "$LOCATION_PATH/backup/$i/plugins.zip" -d "$LOCATION_PATH/$i/wp-content/" &&
          echo -e "${GREEN} $LOCATION_PATH/backup/$i/plugins unzipped" &&
          unzip -q "$LOCATION_PATH/backup/$i/uploads.zip" -d "$LOCATION_PATH/$i/wp-content/" &&
          echo -e "${GREEN} $LOCATION_PATH/backup/$i/uploads unzipped";
        fi
        cp "$LOCATION_PATH/backup/$i/wp-config.php" "$LOCATION_PATH/$i/";
        echo -e "${GREEN} Wordpress directories unzipped";
        echo -e "${YELLOW} Restoring DB for $i";
        DB_FILE=$(ls "$LOCATION_PATH/backup/$i" | grep .sql);
        # mysql -u root --password admin < "$LOCATION_PATH/backup/$i/$DB_FILE" 2>&1 && echo -e "${GREEN} DB Restored";
        DUMP=$(mysql -u root --password"" < "$LOCATION_PATH/backup/$i/$DB_FILE" 2>&1)
        echo "Dump $DUMP";
        echo -e "${GREEN} DB Restored";
      fi
    done
    echo -e "${YELLOW} TERMINATING...";
    sudo rm -rf "$LOCATION_PATH/backup";
    echo -e "${GREEN} TERMINATE";
  else
    echo -e "${RED} $BACKUP_PATH file not exist";
  fi

}

restore_wordpress "$@";