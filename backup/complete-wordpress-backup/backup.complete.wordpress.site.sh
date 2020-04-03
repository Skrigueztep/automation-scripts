#!/usr/bin/env bash
##########################################
###           Complete Wordpress Backup
###
###   Author: Israel Olvera
###   Version: 1.1
###
###   Notes:
###     To run successfully this script you need that you wordpress blog
###     directory and your wordpress database name be the same.
###
##########################################

# Directory to store backup
BACKUP_DIR="$HOME"

# Aditional directory path to backup
# DIR_TO_BACKUP="/var/www/html"
DIR_TO_BACKUP="/opt/lampp/htdocs"

DATE=$(date +%d-%m-%Y)
TIME=$(date +"%T")

# Array with wordpress blogs names
BLOGS=(
  "skrigueztep"
)

DIRECTORIES=(
  "languages"
  "plugins"
  "themes"
  "uploads"
)

for i in "${BLOGS[@]}";
do
  DIR_NAME=$i

  # Validate if Database backup.config file exist
  if [ ! -f "$HOME/backup.config" ]; then
    echo "Move backup.config file to $HOME"
    exit
  fi

  if [ "$(stat -c "%a" "$HOME/backup.config")" != "600" ]; then
    echo "You need assign 600 permission to backup.config file"
    exit
  fi

  # Validate Backup directory existance
  if [ ! -d "$HOME/backup" ]; then
    mkdir "$HOME/backup"
    echo "Backup directory created"
  fi

  # Validate Backup Log file existance
  if [ ! -f "$HOME/backup-script.log" ]; then
    touch "$HOME/backup-script.log"
    echo "Backup log file created"
  fi

  if [ ! -f "$DIR_TO_BACKUP/$DIR_NAME/wp-config.php" ];then
    echo "wp-config.php cannot read beacuse this not exist"
    echo "YOU NEED REINSTALL YOUR BLOG"
    exit
  fi

  # Read wp-config.php file to get blog DB credentials:
  # https://stackoverflow.com/questions/7586995/read-variables-from-wp-config-php
  DB_NAME=$(cat "$DIR_TO_BACKUP/$DIR_NAME/wp-config.php" | grep DB_NAME | cut -d \' -f 4)
  echo "$DB_NAME"

  echo "DATABASE BACKUP IN PROCESS..."
  # This should create a database backup of the blog'
  # TODO: Validate successful execution
  # DB_TEST=$(mysqldump -u root -padmin --databases "$DB_NAME" > "$BACKUP_DIR/backup/$DIR_NAME-backup-$TIME-$DATE.sql")
  DB_TEST=$(mysqldump -u root --databases "$DB_NAME" > "$BACKUP_DIR/backup/$DIR_NAME-backup-$TIME-$DATE.sql")
  if [ "$DB_TEST" ]; then
     echo "Error at execution mysqldump"
     exit
  fi

  echo "DIRECTORY BACKUP..."
  # This shuold create a .zip of directory compressed
  # Validate if each directory exist
  # Zip all important wordpress directories

  for index in "${DIRECTORIES[@]}"
  do
    if [ ! -d "$DIR_TO_BACKUP/$DIR_NAME/wp-content/$index" ]; then
      echo "$DIR_NAME/wp-content/$index directory not exist"
    else
      if [ ! -d "$HOME/backup/$DIR_NAME" ]; then
        mkdir -p "$HOME/backup/$DIR_NAME"
      fi
      zip -9 -r -q "$HOME/backup/$DIR_NAME/$index.zip" "$DIR_TO_BACKUP/$DIR_NAME/wp-content/$index"
      # TODO: Validate successful execution, if this were to fail, delete "$DIR_TO_BACKUP/$DIR_NAME" directory and exit
    fi
  done

  for directory in "${DIRECTORIES[@]}"
  do
    if [ ! -f "$BACKUP_DIR/backup/$DIR_NAME/$directory.zip" ]; then
      echo "$BACKUP_DIR/backup/$DIR_NAME/$directory.zip file not exist"
      exit
    fi
  done

  echo "Backup at $DIR_NAME already";

done

echo "CREATING ZIP OF BACKUP..."
zip -9 -r -q "backup-$DATE.zip" "backup"
if [ ! -f "backup-$DATE.zip" ];then
  rm -rf "$HOME/backup"
  echo "backup-$DATE.zip not created"
  exit
fi

echo "TERMINATING..."
# Print log: https://askubuntu.com/questions/103643/cannot-echo-hello-x-txt-even-with-sudo
echo "Backup $DATE generated at $TIME" | tee -a "$HOME/backup-script.log"
rm -rf "$HOME/backup"
echo "TERMINATE"
exit 0