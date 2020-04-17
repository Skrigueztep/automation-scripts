# Complete Wordpress Backup

    Current Version: 2.2

This script save the following directories of your blogs:

    wp-content/languages
    wp-content/themes
    wp-content/plugins
    wp-content/uploads
    wp-config.php
    
then it make a blog db dump. <br>

    LOG -> $HOME/backup-script.log | Shows all dates of all backups made
    BACKUP Files -> $HOME | All backups save here

# Notes

    If you want execute this script, do the following:
    
    backup.complete.wordpress.site.sh <site1-path> <site2-path>
    
    The paths cannot contain the last slash at the end:
    CORRECT: /home/user/sites/site1
    BAD:    /home/user/sites/site1/

# Requirements

1.- Wordpress Installed & configured <br>
2.- Have at least one wordpress blog <br>

# Instructions

1.- Change .sh permissions to 755 <br>

Note: <br>
ONLY ON UBUNTU SYSTEM <br>
If it doesn't work run: <br>
<b>sudo -H -u user path/backup.complete.wordpress.site.sh</b>