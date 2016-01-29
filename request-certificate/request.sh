#!/bin/bash

# Your email address, used for recovery and revoking certs
LE_ACCOUNT="name@example.com"
WELL_KNOWN_DIR="/opt/ssl-challenge/"
LE_EXECUTABLE="letsencrypt-auto" # Path to your script if not in env PATH

# No options specifies production certificates
SERVER_OPTIONS=''
# Specifies staging certificates, not usable in production
# Comment out the line below for production certificates.
SERVER_OPTIONS='--server https://acme-staging.api.letsencrypt.org/directory'


print_usge() {
    echo "Usage: ./request.sh <domain_file>"
    echo "domain_file contains a list of domains you want included in your"
    echo "SSL certificate"
    echo "The first item in the list will be treated as a CN"
}

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

# Check that the given domain file exists
DOMAIN_FILE=$1
if [ ! -f $DOMAIN_FILE ]; then
    echo 'Specified file "'$DOMAIN_FILE'" does not exist!'
    return 1
fi

DOMAIN_NAME=$(read_domains $DOMAIN_FILE)
UPDATE_COMMAND="letsencrypt-auto certonly --webroot --renew-by-default --agree-tos --email $LE_ACCOUNT $SERVER_OPTIONS -w $WELL_KNOWN_DIR $DOMAIN_NAME"
RELOAD_WEBSERVER='service nginx reload'

$UPDATE_COMMAND
$RELOAD_WEBSERVER
