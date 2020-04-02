#!/usr/bin/env bash
##########################################
###           Complete Wordpress Backup
###
###   Author: Israel Olvera
###   Version: 1.0
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
fi

# Validate Backup Log file existance
if [ ! -f "$HOME/backup-script.log" ]; then
  touch "$HOME/backup-script.log"
fi

# Array with wordpress blogs names
BLOGS=(
  "wordpress"
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

  echo "DATABASE BACKUP IN PROCESS..."
  # This should create a database backup of the blog'
  # TODO: Validate successful execution (2>&1)
  DB_TEST=$(mysqldump -u root "$i" -i | zip -9 > "$BACKUP_DIR/backup/$DIR_NAME-backup-$TIME-$DATE.sql.zip")
  if [ ! "$DB_TEST" ]; then
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
      zip -9 -r -q "$BACKUP_DIR/$DIR_NAME/wp-content/$index.zip" "$DIR_TO_BACKUP/$DIR_NAME/$index"
    fi
  done

  # TODO: Validate successful execution on each zip
  zip -9 -r -q "$BACKUP_DIR/backup/$DIR_NAME.zip" "$DIR_TO_BACKUP/$DIR_NAME"
  if [ ! -f "$BACKUP_DIR/backup/$DIR_NAME.zip" ]; then
    exit
  fi

  echo "Backup at $DIR_NAME already";

  # if [ ! -d "$DIR_TO_BACKUP/$DIR_NAME/wp-content/languages" ]; then
  #   echo "wp-content/languages directory not exist for $DIR_NAME"
  # else
  #   zip -9 -r -q "$BACKUP_DIR/$DIR_NAME/wp-content/languages.zip" "$DIR_TO_BACKUP/$DIR_NAME/languages"
  # fi

  # if [ ! -d "$DIR_TO_BACKUP/$DIR_NAME/wp-content/plugins" ]; then
  #   echo "wp-content/plugins directory not exist for $DIR_NAME"
  #   exit
  # else
  #   zip -9 -r -q "$BACKUP_DIR/$DIR_NAME/wp-content/plugins.zip" "$DIR_TO_BACKUP/$DIR_NAME/plugins"
  # fi

  # if [ ! -d "$DIR_TO_BACKUP/$DIR_NAME/wp-content/themes" ]; then
  #   echo "wp-content/themes directory not exist for $DIR_NAME"
  #   exit
  # else
  #   zip -9 -r -q "$BACKUP_DIR/$DIR_NAME/wp-content/themes.zip" "$DIR_TO_BACKUP/$DIR_NAME/themes"
  # fi

  # if [ ! -d "$DIR_TO_BACKUP/$DIR_NAME/wp-content/uploads" ]; then
  #   echo "wp-content/themes directory not exist for $DIR_NAME"
  #   exit
  # else
  #   zip -9 -r -q "$BACKUP_DIR/$DIR_NAME/wp-content/uploads.zip" "$DIR_TO_BACKUP/$DIR_NAME/uploads"
  # fi
done

echo "CREATING ZIP OF BACKUP..."
zip -9 -r -q "backup-$DATE.zip" "backup"
if [ ! -f "backup-$DATE.zip" ];then
  echo "backup-$DATE.zip not created"
  exit
fi

echo "TERMINATING..."
# Print log: https://askubuntu.com/questions/103643/cannot-echo-hello-x-txt-even-with-sudo
echo "Backup $DATE generated at $TIME" | tee -a "$HOME/backup-script.log"
rm "$BACKUP_DIR/backup/$DIR_NAME.zip"
rm "$BACKUP_DIR/backup/compĺete-backup-$TIME-$DATE.sql.zip"
rm "$HOME/backup"
echo "TERMINATE"
exit 0