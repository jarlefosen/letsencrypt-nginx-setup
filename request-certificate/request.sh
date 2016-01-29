#!/bin/bash

DOMAIN_FILE=$1
WELL_KNOWN_DIR="/opt/ssl-challenge/"
LETSENCRYPT_ACCOUNT="name@example.com"
SERVER_OPTIONS='--server https://acme-staging.api.letsencrypt.org/directory'

read_domains() {

    filename="$1"
    DOMAINS=""
    while read -r line || [[ -n "$line" ]]; do
        # Only add non-empty lines
        if [ ! -z $line ]; then
            DOMAINS="$DOMAINS -d $line"
        fi
    done < "$filename"

    echo $DOMAINS
}

if [ ! -f $DOMAIN_FILE ]; then
    echo 'Specified file "'$DOMAIN_FILE'" does not exist!'
    return 1
fi

DOMAIN_NAME=$(read_domains $DOMAIN_FILE)
UPDATE_COMMAND="letsencrypt-auto certonly --webroot --renew-by-default $SERVER_OPTIONS -w $WELL_KNOWN_DIR $DOMAIN_NAME"
RELOAD_WEBSERVER='service nginx reload'

$UPDATE_COMMAND
$RELOAD_WEBSERVER
