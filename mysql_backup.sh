
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

#------------------------------------------------------------------------------
## date format ##
#------------------------------------------------------------------------------
NOW=$(date +"%F")
NOWT=$(date +"%T")


## Backup path ##
DF="$(which df)"

#------------------------------------------------------------------------------
BACK_UP_PATH="/Users/vivek/backup/mysql"
#TMP_FILE="/var/backup/mysql/mailbody.txt"
TMP_MSG_FILE="/tmp/mailbody.msg"

#------------------------------------------------------------------------------
#Mysql credentials for root
#------------------------------------------------------------------------------
MYSQL_HOST="127.0.0.1"
MYSQL_USER="root"
MYSQL_PASS="root"

#------------------------------------------------------------------------------
# Owner of mysql backup dir
#------------------------------------------------------------------------------
OWNER="root"

#------------------------------------------------------------------------------
# Group of mysql backup dir
#------------------------------------------------------------------------------
GROUP="staff"


#------------------------------------------------------------------------------
## Binary path ##
#To find the path of the mysql executable
#------------------------------------------------------------------------------
MYSQL="$(which mysql)"

#------------------------------------------------------------------------------
#To find the path of the mysqldump executable
#------------------------------------------------------------------------------
MYSQLDUMP="$(which mysqldump)"

#------------------------------------------------------------------------------
#To find the path of the GZIP/chown/chmod executable
#------------------------------------------------------------------------------
GZIP="$(which gzip)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"

#------------------------------------------------------------------------------
#To find the path of the Mail executable
#------------------------------------------------------------------------------
MAIL="$(which mail)"

#------------------------------------------------------------------------------
# Mail Parameters
#------------------------------------------------------------------------------
SUBJECT="MySQL backup"
EMAIL="vivek@weboniselab.com"
# Send Result EMail
SEND_EMAIL=1
NOTIFY_EMAIL="vivek@weboniselab.com"
NOTIFY_SUBJECT="MySQL Backup Notification"

# Get data in yyyy-mm-dd format
NOW="$(date +"%Y%m%d")"

# mysqldump parameters
DUMP_OPTS="-Q --skip-lock-tables --single-transaction"

#------------------------------------------------------------------------------
# Function for generating Email
#------------------------------------------------------------------------------
function gen_email {
  DO_SEND=$1
  TMP_FILE=$2
  NEW_LINE=$3
  LINE=$4
  if [ $DO_SEND -eq 1 ]; then
    if [ $NEW_LINE -eq 1 ]; then
      echo "$LINE" >> $TMP_FILE
    else
      echo -n "$LINE" >> $TMP_FILE
    fi
  fi
}

# Create backup directory
MBD="$BACK_UP_PATH/$NOW"
if [ ! -d "$MBD" ]; then
  mkdir "$MBD"
  # Only $OWNER.$GROUP can access it!
  $CHMOD 0777 $BACK_UP_PATH
  $CHOWN $OWNER:$GROUP -R $BACK_UP_PATH
  $CHMOD 0777 $BACK_UP_PATH
fi

#------------------------------------------------------------------------------
## #From this we get the list of databases present on the server ##
MYSQL_DB_LIST="$($MYSQL -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PASS -Bse 'show databases')"
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
## Use shell loop to backup each db ##
#------------------------------------------------------------------------------
#start_time=$(date +%s)
echo "Script started successfully $NOW"
#backup_error=0
set -o pipefail

# Start backing up databases
STARTTIME=$(date +%s)
for db in $MYSQL_DB_LIST
do
 FILE="$MBD/mysql-$db-$NOWT.gz"
# echo "$MYSQLDUMP -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PASS $db | $GZIP -9 > $FILE"
 $MYSQLDUMP $DUMP_OPTS -u $MYSQL_USER -h $MYSQL_HOST -p$MYSQL_PASS $db | $GZIP -9 > "$FILE"
 ERR=$?
 if [ $ERR != 0 ]; then
   NOTIFY_MESSAGE="Error: $ERR, while backing up database: $db"
 else
   echo "$(du -hs $FILE )"
   SIZE=$(du -hs $FILE | awk '{print $1 '\n'}')
   NOTIFY_MESSAGE="Successfully backed up database: $db Size:$SIZE"
 fi
 gen_email $SEND_EMAIL $TMP_MSG_FILE 1 "$NOTIFY_MESSAGE"
 echo $NOTIFY_MESSAGE
done
ENDTIME=$(date +%s)
DIFFTIME=$(( $ENDTIME - $STARTTIME ))
DUMPTIME="$(($DIFFTIME / 60)) minutes and $(($DIFFTIME % 60)) seconds."


#------------------------------------------------------------------------------
# Empty line in email and stdout
#------------------------------------------------------------------------------
gen_email $SEND_EMAIL $TMP_MSG_FILE 1 ""
echo ""

#------------------------------------------------------------------------------
# Log Time
#------------------------------------------------------------------------------
gen_email $SEND_EMAIL $TMP_MSG_FILE 1 "mysqldump took: ${DUMPTIME}"
echo "mysqldump took: ${DUMPTIME}"

#------------------------------------------------------------------------------
# Empty line in email and stdout
#------------------------------------------------------------------------------
gen_email $SEND_EMAIL $TMP_MSG_FILE 1 ""
echo ""

#------------------------------------------------------------------------------
# Empty line in email and stdout
#------------------------------------------------------------------------------
gen_email $SEND_EMAIL $TMP_MSG_FILE 1 ""
echo ""

#------------------------------------------------------------------------------
# Add disk space stats of backup filesystem
#------------------------------------------------------------------------------
if [ $SEND_EMAIL -eq 1 ]; then
  $DF -h "$BACK_UP_PATH" >> "$TMP_MSG_FILE"
fi
$DF -h "$BACK_UP_PATH"

#------------------------------------------------------------------------------
# Sending notification email
#------------------------------------------------------------------------------
if [ $SEND_EMAIL -eq 1 ]; then
  $MAIL -s "$NOTIFY_SUBJECT" "$NOTIFY_EMAIL" < "$TMP_MSG_FILE"
  echo "$TMP_MSG_FILE"
  rm -f "$TMP_MSG_FILE"
fi
