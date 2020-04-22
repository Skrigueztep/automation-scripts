# Restore Wordpress Backup

    Current Version: 2.0

# Notes
    
    1.- You need execute with root permissions.

    Restore all website on backup:
        ./restore.backup.wordpress.sh <.zip file path> <Location to unzip>
        
    Restore only one website:
        ./restoer.backup.wordpress.sh -s <site-name> <.zip file path> <location to unzip>
      or
        ./restoer.backup.wordpress.sh --single <site-name> <.zip file path> <location to unzip>