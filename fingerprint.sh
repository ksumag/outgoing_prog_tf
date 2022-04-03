#!/bin/bash

set -e
eval "$(jq -r '@sh "access=\(.access) key=\(.key)"')"

fingerprint=`curl -s -X GET -H "Content-Type: application/json"  -H "Authorization: Bearer $access" "https://api.digitalocean.com/v2/account/keys?per_page=100" | jq '.ssh_keys' | grep -i "$key"  -2 | grep fingerprint | cut -f4 -d'"' `
 echo {\"fingerprint\": \"$fingerprint\"} 
 
 
