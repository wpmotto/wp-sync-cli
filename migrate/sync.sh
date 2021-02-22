#!/usr/bin/env bash

# Exit if command fails
set -e

## VARIABLES
ENV=production
GITREPO=git@gitlab.com:mottodesignstudio/motto-wp.git
REMOTEURL=preprod.motto.ca
LOCALURL=motto.test
REMOTEWPPATH=/www/motto_495/public
REMOTEDBPATH=/www/motto_495/db.sql
LOCALDBPATH=~/Downloads/db.sql
SSHCONNECT=motto@35.203.98.50
SSHPORT=58074
DBNAME=wp_motto
DBUSER=root
DBPASS=
DBHOST=localhost
THEMENAME=motto
MYSQL=`which mysql`

ssh $SSHCONNECT -p $SSHPORT << EOF
cd $REMOTEWPPATH
wp db export $REMOTEDBPATH
exit
EOF
rsync -avz -e "ssh -p${SSHPORT}" $SSHCONNECT:$REMOTEDBPATH $LOCALDBPATH
wp db import $LOCALDBPATH
wp search-replace //$REMOTEURL //$LOCALURL

cd ..
rsync -avz -e "ssh -p${SSHPORT}" --progress --exclude wp-config.php --exclude 'mu-plugins' --exclude 'themes' $SSHCONNECT:$REMOTEWPPATH/* .

## Post Cleanup
wp plugin install log-emails disable-emails --activate
wp cache flush
