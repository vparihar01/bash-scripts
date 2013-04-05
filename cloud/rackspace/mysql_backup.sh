#!/bin/bash
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


#Log files path for mysql backup
PATHS="/var/backup/mysql"
LOG="$PATHS/logs/cloud.log"



#All output from this command should be shoved into a black hole.
#That’s one good way to make a program be really quiet!
CURL=`which curl 2>/dev/null`

# -s option Don't show progress meter or error messages. Makes Curl mute.
# -K option All SSL connections are attempted to be made secure by
#using the CA certificate bundle installed by default..
CURL="$CURL -s -k"

#This could be used to change the Rackspace Api version
VERSION="v2.0"

#To find the path of the mysql executable
MYSQL="$(which mysql)"

#To find the path of the mysqldump executable
MYSQLDUMP="$(which mysqldump)"

CHOWN="$(which chown)"
CHMOD="$(which chmod)"

#To find the path of the GZIP executable
GZIP="$(which gzip)"

db_dump_name="$(hostname -f).$(date +"%Y.%m.%d_%H.%M")"

#Mysql credentials for root
#Host for the rack space cloud database
MYSQL_HOST="*****************.rackspaceclouddb.com"
MYSQL_USER="mysql_root_username"
MYSQL_PASS="mysql_root_password"

#From this we get the list of databases present on the server and log everything to mysql_backup.error log
MYSQL_DB_LIST="$($MYSQL -u $MYSQL_USER -h $MYSQL_HOST $MYSQL_PASS -Bse 'show databases')" 2>>$PATHS/mysql_backup.error

$MYSQLDUMP -h $MYSQL_HOST -u $MYSQL_USER -p'$MYSQL_PASS' crucible_live_db | $GZIP > /var/www/mysql_backup/crucible_live_db_`date '+%m-%d-%Y-%T'`.sql.gz

# Now we iterate over the list of databases present in our server
for db in $MYSQL_DB_LIST
do
  FILE="$PATHS/$db.$db_dump_name.gz" #FILE is the name and path where mysql dump get stored
  $MYSQLDUMP -u$MYSQL_USER -h$MYSQL_HOST $MYSQL_PASS $db 2>>$PATHS/mysql_backup.error | $GZIP -9 > $FILE 2>>$PATHS/mysql_backup.error && echo "mysql: $db dumped OK" >>$PATHS/mysql_backup.log
done