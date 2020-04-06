#!/usr/bin/env bash
##########################################
###           Complete Wordpress Backup
###
###   Author: Israel Olvera
###   Version: 2.0
###
###   NOTES:
###     This version cannot require backup.config file, and not require modify the script
###     To execute:   backup.complete.wordpress.site.sh <site1-path> <site2-path>
###     At the end of each path no add the last /, example: /home/user/sites/site1
###
##########################################

# Directory to store backup
BACKUP_DIR="$HOME"

DATE=$(date +%d-%m-%Y)
TIME=$(date +"%T")

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'

DIRECTORIES=(
  "languages"
  "plugins"
  "themes"
  "uploads"
)

function backup() {
  COUNTER=0

  ################################### Validate wordpress directory ##############################################
  # Iterate parameters: https://unix.stackexchange.com/questions/129072/whats-the-difference-between-and
  for i in "$@";
  do
    if [ -d "$i" ]; then
      if [ ! -d "$i/wp-content" ];then
        echo -e "${YELLOW} $i is not a wordpress directory";
        COUNTER=$((COUNTER+1))
      fi
    else
      echo "${YELLOW} $i not exist";
      COUNTER=$((COUNTER+1))
    fi
  done

  if [ $COUNTER -eq 0 ];then
    ###################################### INITIAL VALIDAITONs ##################################################
    # Validate Backup directory existance
    if [ ! -d "$BACKUP_DIR/backup" ]; then
      mkdir "$BACKUP_DIR/backup"
      echo -e "${GREEN} Backup directory created"
    fi

    # Validate Backup Log file existance
    if [ ! -f "$BACKUP_DIR/backup-script.log" ]; then
      touch "$BACKUP_DIR/backup-script.log"
      echo -e "${GREEN} Backup log file created"
    fi

    if [ ! -f "$i/wp-config.php" ];then
       echo -e "${YELLOW} $i/wp-config.php cannot read beacuse this not exist"
       echo -e "${RED} YOU NEED REINSTALL YOUR BLOG"
       exit 2
    fi

    for path in "$@";
    do
      ####################################################################################################################
      # Read wp-config.php file to get blog DB credentials:
      # https://stackoverflow.com/questions/7586995/read-variables-from-wp-config-php
      DB_NAME=$(cat "$path/wp-config.php" | grep DB_NAME | cut -d \' -f 4);

      # Get last directory of a path
      # https://stackoverflow.com/questions/10986794/remove-part-of-path-on-unix
      DIR_NAME=$(echo "$path" | rev | cut -d'/' -f-1 | rev)

      # This should create a database backup of the blog'
      # TODO: Validate successful execution
      echo -e "${YELLOW} DATABASE BACKUP IN PROCESS..."
      # mysqldump -u root -padmin --databases "$DB_NAME" > "$i.sql"
      mysqldump -u root --databases "$DB_NAME" > "$BACKUP_DIR/backup/$DIR_NAME-backup-$TIME-$DATE.sql"
      if [ ! -f "$BACKUP_DIR/backup/$DIR_NAME-backup-$TIME-$DATE.sql" ]; then
         echo -e "${RED} Error at execution mysqldump"
         exit 2
      fi
      echo -e "${GREEN} DB of ${DIR_NAME} saved!"
      echo -e "${YELLOW} DIRECTORY BACKUP..."
      # This shuold create a .zip of directory compressed
      # Validate if each directory exist
      # Zip all important wordpress directories
      for index in "${DIRECTORIES[@]}"
      do
        if [ ! -d "$path/wp-content/$index" ]; then
          echo -e "${RED} $path directory not exist"
        else
          if [ ! -d "$BACKUP_DIR/backup/$DIR_NAME" ]; then
            mkdir -p "$BACKUP_DIR/backup/$DIR_NAME"
          fi
          cd "$path/wp-content/" && zip -9 -r -q "$BACKUP_DIR/backup/$DIR_NAME/$index.zip" "$index"
          echo "$path/wp-content/$index > $BACKUP_DIR/backup/$DIR_NAME/$index.zip"
          # TODO: Validate successful execution, if this were to fail, delete "$DIR_TO_BACKUP/$DIR_NAME" directory and exit
        fi
      done

      for directory in "${DIRECTORIES[@]}"
      do
        if [ ! -f "$BACKUP_DIR/backup/$DIR_NAME/$directory.zip" ]; then
          echo "$BACKUP_DIR/backup/$DIR_NAME/$directory.zip file not exist"
          exit 2
        fi
      done

      echo -e "${GREEN} Backup at $DIR_NAME already";
    done
    echo -e "${YELLOW} CREATING ZIP OF BACKUP..."

    cd "$BACKUP_DIR" && zip -9 -r -q "backup-$DATE.zip" "backup/"
    if [ ! -f "$BACKUP_DIR/backup-$DATE.zip" ];then
      rm -rf "$BACKUP_DIR/backup"
      echo "backup-$DATE.zip not created"
      exit 2
    fi

    echo -e "${YELLOW} TERMINATING..."
    # Print log: https://askubuntu.com/questions/103643/cannot-echo-hello-x-txt-even-with-sudo
    echo "Backup $DATE generated at $TIME" | tee -a "$BACKUP_DIR/backup-script.log"
    rm -rf "$BACKUP_DIR/backup"
    echo -e "${YELLOW} TERMINATE"
    exit 0
  else
    exit 2
  fi
}

backup "$@";