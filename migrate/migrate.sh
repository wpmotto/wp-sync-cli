#!/usr/bin/env bash

# Exit if command fails
set -e

## VARIABLES
ENV=production
REMOTEURL=preprod.motto.ca
LOCALURL=motto.test
REMOTEWPPATH=/www/motto_495/public
SSHCONNECT=motto@35.203.98.50
SSHPORT=58074
DBNAME=wp_motto
DBUSER=root
DBPASS=
DBHOST=localhost

## Sync Files
rsync -avz -e "ssh -p${SSHPORT}" --progress $SSHCONNECT:$REMOTEWPPATH/wp-content/. .

## Update WP Config
# wp config set DISABLE_WP_CRON true --raw
# wp config set WP_DEBUG_LOG true --raw
# wp config set WP_SITEURL "https://${LOCALURL}"
# wp config set WP_HOME "https://${LOCALURL}"
# wp config set DB_NAME $DBNAME
# wp config set DB_USER $DBUSER
# wp config set DB_PASSWORD "${DBPASS}"
# wp config set DB_HOST $DBHOST

## Pull DB
wp @$ENV search-replace "//${REMOTEURL}" "//${LOCALURL}" --export | wp db import -

## Post Cleanup
wp cache flush