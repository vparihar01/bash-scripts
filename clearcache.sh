#!/bin/sh
# Every hour the cron job will run this command and clear any memory cache that has built up.
# Linux OS may at times decide that the Cached memory is being used and is needed
# which can lead to memory related issues and ultimately rob your server of any
# potentially free memory. To combat this you can force the Linux OS to free up and stored Cached memory.
# It checks if cache memory is more than 700 Mb it drop caches and send mail to user.
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
LOG_CACHE="Script/drop_cache_log.msg"

TMP_MSG_FILE="/tmp/mailbody.msg"

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
NOW=$(date +"%F")
NOWT=$(date +"%T")

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

#High RAM usage checker
CACHE_MEM=`free -m |awk 'NR==2' |awk '{ print$7 }'`
FREE_RAM=`free -m |awk 'NR==2' |awk '{ print$4 }'`
echo "--------------------------------------------------------" >> $LOG_CACHE
echo "High RAM usage checker started at $NOW" >> $LOG_CACHE
if [ $CACHE_MEM -gt 700 ];
then
NOTIFY_MESSAGE="Error: Cache Memory is high: $CACHE_MEM !!!!!!! Free Memory is low: $FREE_RAM !!!!!!! Droping Cache date: $NOW time: $NOWT"
echo "$NOTIFY_MESSAGE" >> $LOG_CACHE
sync; sudo echo 1 > /proc/sys/vm/drop_caches
echo "Page Cache dropped !!!! Cache Memory now: `free -m |awk 'NR==2' |awk '{ print$7 }'` !!!! Free Memory is: `free -m |awk 'NR==2' |awk '{ print$4 }'`" >> $LOG_CACHE
exit
else
echo "Info: Cache Memory is low: $CACHE_MEM !!!!!!! Free Memory Normal: $FREE_RAM" >> $LOG_CACHE
echo "Info: Date: $NOW time: $NOWT" >> $LOG_CACHE
fi
echo "--------------------------------------------------------" >> $LOG_CACHE


gen_email $SEND_EMAIL $TMP_MSG_FILE 1 "$NOTIFY_MESSAGE"

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
# Sending notification email
#------------------------------------------------------------------------------
if [ $SEND_EMAIL -eq 1 ]; then
  $MAIL -s "$NOTIFY_SUBJECT" "$NOTIFY_EMAIL" < "$TMP_MSG_FILE"
  echo "$TMP_MSG_FILE"
  rm -f "$TMP_MSG_FILE"
fi
