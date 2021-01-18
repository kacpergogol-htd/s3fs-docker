#!/bin/bash
#https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-sync

TRIGGER_FILE=${TRIGGER_FILE:-.do_upload}
SYNC_FROM=${SYNC_FROM:-/var/www/html/wp-content/s3}
PARAMS=${PARAMS:---acl public-read}
BUCKET=${BUCKET:-zoomcms.htdwork.com}
FILES_TO_REMOVE=${TRIGGER_FILE},.lock
TTL=${TTL:-1200}

LOCKFILE=$SYNC_FROM/.lock

while true
do
sleep 0.1

if [ -f "$SYNC_FROM/$TRIGGER_FILE" ]; then

        NOW=$(date +"%m-%d-%Y-%T")

        if (set -o noclobber; echo "$$" > "$LOCKFILE") 2> /dev/null;
        then
                trap 'rm -f "$LOCKFILE"; exit $?' INT TERM EXIT

                echo "Syncing & Cleaning deploy file... $NOW"
                /usr/local/bin/aws s3 sync ${SYNC_FROM} s3://${BUCKET}/ ${PARAMS}
                for file in $(echo $FILES_TO_REMOVE | sed "s/,/ /g")
                do
                        /usr/local/bin/aws s3 rm s3://${BUCKET}/$file
                done
                rm -f "$LOCKFILE"
                rm ${SYNC_FROM}/${TRIGGER_FILE}
                trap - INT TERM EXIT
        else
                echo "Failed to acquire lock-file: $LOCKFILE. waiting..."
		if [ $(($(date +%s)-$(stat -c "%Y" $LOCKFILE))) -gt $TTL ]; then
			rm -f "$LOCKFILE"
			echo "Lock file older then ${TTL}s - so removing..."
        	fi
		sleep 60        
        fi
fi
done
