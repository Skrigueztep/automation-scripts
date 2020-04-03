# Complete Wordpress Backup

# NOTE

    If you try to run this script and not work, try run it from $HOME

# Requirements

1.- Wordpress Installed & configured <br>
2.- At least one wordpress blog <br>
3.- Wordpress blog DB named equal blog

# Instructions

1.- Copy the following files to $HOME <br>
    - backup.complete.wordpress.site.sh <br>
    - backup.config <br>
    <br>
2.- Change .sh and .config files permissions to 600 <br>
3.- Change credentials on .config file to your owns <br>
4.- Change DIR_TO_BACKUP for your wordpress sites location <br>
5.- Changes BLOGS for yuor sites to backup <br>
    Ej: BLOGS=( "site1" "site2" "site3" ... )

Note: <br>
ONLY ON UBUNTU SYSTEM <br>
If it doesn't work run: <br>
<b>sudo -H -u <user> $HOME/backup.complete.wordpress.site.sh</b>