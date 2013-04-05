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

#All output from this command should be shoved into a black hole.
#That’s one good way to make a program be really quiet!
CURL=`which curl 2>/dev/null`

# -s option Don't show progress meter or error messages. Makes Curl mute.
# -K option All SSL connections are attempted to be made secure by
#using the CA certificate bundle installed by default..
CURL="$CURL -s -k"

#This could be used to change the Rackspace Api version
VERSION="v2.0"

#Rackspace API url for UK
API_URL="lon.identity.api.rackspacecloud.com"

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#TimeStamp for Snapshot Naming
TIMESTAMP=live2_`date +%d-%m-%Y-%T`




#API call to retrieve Auth Token from RackSpace Auth API v2.2
TOKEN_VARIABLE=$($CURL -X POST https://$API_URL/$VERSION/tokens -d '{ "auth":{ "RAX-KSKEY:apiKeyCredentials":{ "username":"rack_space_server_username", "apiKey":"rack_space_server_api_key" } } }' -H "Content-type: application/json" | jshon -e access -e token -e id)

#Token occupied to token_variable
echo "Token provided by API"
echo $TOKEN_VARIABLE


#RackSpace API call to create instance snapshot
$CURL -i -X POST https://$API_URL/$VERSION/ACCOUNT-ID/servers/SERVER-UUID/action -H "X-Auth-Token:`echo $TOKEN_VARIABLE | sed -r 's/"//g'`" -d '{"createImage" : {"name" : "'"$TIMESTAMP"'"}}' -H "Content-type: application/json"
