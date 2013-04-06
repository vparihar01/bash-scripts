
#!/bin/sh
# Dump MySQL database every hour using cron
# Copyright (C) 2013 Vivek Parihar
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ---------------------------------------------------------------------------------------------------------

## date format ##
NOW=$(date +"%F")
NOWT=$(date +"%T")

## Backup path ##
BACK_UP_PATH="/var/backup/mysql/$NOW"

#Mysql credentials for root
MYSQL_HOST="127.0.0.1"
MYSQL_USER="mysql_root_username"
MYSQL_PASS="mysql_root_password"


## Binary path ##
#To find the path of the mysql executable
MYSQL="$(which mysql)"

#To find the path of the mysqldump executable
MYSQLDUMP="$(which mysqldump)"

#To find the path of the GZIP executable
GZIP="$(which gzip)"

## #From this we get the list of databases present on the server ##
MYSQL_DB_LIST="$($MYSQL -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PASS -Bse 'show databases')"

## Use shell loop to backup each db ##
for db in $MYSQL_DB_LIST
do
 FILE="$BACK_UP_PATH/mysql-$db-$NOWT.gz"
 echo "$MYSQLDUMP -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PASS $db | $GZIP -9 > $FILE"
done
