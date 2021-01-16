#!/bin/bash
#https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-sync

TRIGGER_FILE=${TRIGGER_FILE:-.do_upload}
SYNC_FROM=${SYNC_FROM:-/var/www/html/wp-content/s3}
PARAMS=${PARAMS:---acl public-read --delete}
BUCKET=${BUCKET:-zoomcms.htdwork.com}

while true
do
	NOW=$(date +"%m-%d-%Y-%T")
	if [ -f "$SYNC_FROM/$TRIGGER_FILE" ]; then
        	/usr/local/bin/aws s3 sync ${SYNC_FROM} s3://${BUCKET}/ ${PARAMS}
                /usr/local/bin/aws s3 rm s3://${BUCKET}/${TRIGGER_FILE}
	echo "Syncing & Cleaning deploy file... $NOW"
        rm ${SYNC_FROM}/${TRIGGER_FILE}
	fi
done
