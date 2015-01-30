#!/bin/bash

# Automatic backup website data
# Author: FFFLY 
# Website: https://github.com/FFFLY/Automatic-backup-website-data/

# This script needs to use Zip and Lftp. So please make sure you have installed them.

# Configuration settings
# Please edit the configuration settings below.

# FTP settings
FTP_Address=www.yourdomains.com                     # The domain name or IP address.
FTP_Username=username                               # FTP account username.
FTP_Password=password                               # FTP account password.
FTP_Filepath=/backup                                # FTP file path, your backup file will be stored here.

# MySQL settings
MySQL_Path=/mysql                                   # MySQL install path.
MySQL_Username=username                             # Recommended to use the root user account.
MySQL_Password=password                             # MySQL user account password.

# Database settings
Database_Name1=database                             # Database_Name1, Database_Name2, Database_Name3 ...

# Website settings
Website_Path=/www                                   # Website file path. 
Website_Name1=www.yourdomains.com                   # Website_Name1, Website_Name2, Website_Name3 ...

# Local storage settings
Local_Filepath=/backup                              # Local file path, your backup file will be stored here.

# Storage period settings
Local_Storage_Time=7day                             # The local server storage period. 
Remote_Storage_Time=7day                            # The remote server storage period.

# Compression settings
Zip_Password=password                               # Zip File Password.

# Please edit the above configuration settings.

# New backup file name
NewWebBakName=Web_$(date +%Y%m%d)_Bak
NewDataBakName=Data_$(date +"%Y%m%d")_Bak

# Old backup file name
OldWebBakName=Web_$(date -d -$Local_Storage_Time +"%Y%m%d")_Bak
OldDataBakName=Data_$(date -d -$Local_Storage_Time +"%Y%m%d")_Bak
OldRemoteWebBakName=Web_$(date -d -$Remote_Storage_Time +"%Y%m%d")_Bak
OldRemoteDataBakName=Data_$(date -d -$Remote_Storage_Time +"%Y%m%d")_Bak

# Delete expired local backup files
cd $Local_Filepath
rm -f $OldDataBakName.zip
rm -f $OldWebBakName.zip

# Database backup
$MySQL_Path/bin/mysqldump -u$MySQL_Username -p$MySQL_Password --lock-all-tables $Database_Name1 > $Database_Name1.sql
tar acf $NewDataBakName.tar.xz *.sql
zip -qP $Zip_Password $NewDataBakName.zip $NewDataBakName.tar.xz
rm -f *.sql 
rm -f *.tar.xz

# Website backup
tar acf $NewWebBakName.tar.xz -C $Website_Path/ $Website_Name1
zip -qP $Zip_Password $NewWebBakName.zip $NewWebBakName.tar.xz
rm -f *.tar.xz

# Remote backup
lftp $FTP_Address -u $FTP_Username,$FTP_Password << EOF
cd $FTP_Filepath
rm $OldRemoteDataBakName.zip
rm $OldRemoteWebBakName.zip
put $NewDataBakName.zip
put $NewWebBakName.zip
bye
EOF