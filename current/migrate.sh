#!/usr/bin/env bash

# Exit if command fails
set -e

## VARIABLES
REMOTEURL=wordpress-starter.com
LOCALURL=wordpress-starter.test
LOCALDBPATH=~/Downloads/db.sql
REMOTEDBPATH=/home/runcloud/private/db.sql
REMOTEWPPATH=/home/runcloud/webapps/wordpress
SSHSERVER=runcloud@167.99.119.239
SSHPORT=22
RESETVERSIONING=false
SYNCDB=true
SYNCFILES=false

## PROMPTS
# read -p "Would you like to reset your versioning? (y/n)" -n 1 -r
# echo    # (optional) move to a new line
# if [[ ! $REPLY =~ ^[Yy]$ ]]
# RESETVERSIONING=false
# then
# fi

# read -p "Would you like to sync your DB? (y/n)" -n 1 -r
# echo    # (optional) move to a new line
# if [[ ! $REPLY =~ ^[Yy]$ ]]
# SYNCDB=false
# then
# SYNCDB=true
# fi

# read -p "Would you like to sync your files? (y/n)" -n 1 -r
# echo    # (optional) move to a new line
# if [[ ! $REPLY =~ ^[Yy]$ ]]
# SYNCFILES=false
# then
# SYNCFILES=true
# fi

## SCRIPT
if [ "$RESETVERSIONING" = true ] ; then
git fetch
git reset --hard origin/master
fi

if [ "$SYNCDB" = true ] ; then
ssh $SSHSERVER -p $SSHPORT << EOF
cd $REMOTEWPPATH
wp db export $REMOTEDBPATH
exit
EOF
rsync -avz -e "ssh -p${SSHPORT}" $SSHSERVER:$REMOTEDBPATH $LOCALDBPATH
wp db import $LOCALDBPATH
wp search-replace //$REMOTEURL //$LOCALURL
fi

if [ "$SYNCFILES" = true ] ; then
cd ..
rsync -avz -e "ssh -p${SSHPORT}" --progress --exclude wp-config.php --exclude 'mu-plugins' --exclude 'themes' $SSHSERVER:$REMOTEWPPATH/* .
fi

wp plugin deactivate mailchimp-for-woocommerce
wp plugin activate query-monitor
wp plugin deactivate cache-enabler
wp cache flush
