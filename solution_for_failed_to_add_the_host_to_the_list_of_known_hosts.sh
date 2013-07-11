
#!/bin/sh
# Failed to add the host to the list of known hosts (~/.ssh/known_hosts)
# Connection works, but the following warning is issued
# Failed to add the host to the list of known hosts (~/.ssh/known_hosts)
# This error occurs when:
#   - The user's HOME folder has incorrect permissions
#   - The user's ~/.ssh folder or ~/.ssh/known_hosts file has incorrect permissions (such as when the folder has been copied into location by root, or permissions have been manually set incorrectly)

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

#------------------------------------------------------------------------------
# Owner of mysql backup dir
#------------------------------------------------------------------------------
OWNER="$(whoami)"

#------------------------------------------------------------------------------
## Binary path ##
#To find the path of the chown executable
#------------------------------------------------------------------------------
CHOWN="$(which chown)"

#------------------------------------------------------------------------------
#To find the path of the chmod executable
#------------------------------------------------------------------------------
CHMOD="$(which chmod)"

#------------------------------------------------------------------------------
#To find the path of the ssh executable
#------------------------------------------------------------------------------
SSH="$(which ssh)"


echo "Script started successfully $NOW"
#------------------------------------------------------------------------------
#To Change onwer of .ssh directory to $OWNER
#------------------------------------------------------------------------------
echo "--------------------------------------------------------"
echo "Changing onwer of .ssh directory to $OWNER"
$CHOWN -R $OWNER ~/.ssh
echo "Owner changed to $OWNER"
echo "--------------------------------------------------------"

#------------------------------------------------------------------------------
#To fix the permissions if they are not correct i.e 0700
#------------------------------------------------------------------------------
echo "--------------------------------------------------------"
echo "Changing permissions of .ssh directory to 0700"
$CHMOD 700 ~/.ssh
echo"Permissions changed for .ssh directory to 0700"
echo "--------------------------------------------------------"

#------------------------------------------------------------------------------
#To fix the permissions of files inside .ssh directory if they are not correct i.e 0600
#------------------------------------------------------------------------------
echo "--------------------------------------------------------"
echo "Changing files permissions inside .ssh directory to 0600"
$CHMOD 600 ~/.ssh/*
echo "Permissions changed for files inside .ssh directory to 0600"
echo "--------------------------------------------------------"

#------------------------------------------------------------------------------
#To remove the ACL flags from under the .ssh directory
#------------------------------------------------------------------------------
echo "--------------------------------------------------------"
echo "Removing the  ACL flags from .ssh directory"
$CHMOD -R -a# 0 ~/.ssh
echo "Removed ACL flags"
echo "--------------------------------------------------------"

echo "Failed to add the host to the list of known hosts (~/.ssh/known_hosts) is not resolved."
echo "Lets check if it is resolved"

$SSH -T git@github.com
echo ""