#!/bin/bash
#https://docs.aws.amazon.com/cli/latest/userguide/cli-services-s3-commands.html#using-s3-commands-managing-objects-sync

TRIGGER_FILE=${TRIGGER_FILE:-.do_upload}
SYNC_FROM=${SYNC_FROM:-/var/www/html/wp-content/s3}
PARAMS=${PARAMS:---only-show-errors}
PARAMS_FULL=${PARAMS_CLEAN:-${PARAMS} --delete --exclude "media/*"}
BUCKET=${BUCKET:-zoomcms.htdwork.com}
OMMIT=".lock,.sync_log,.do_upload,.do_upload_single"
OMMIT_FILES=$(echo $(for file in $(echo $OMMIT | sed "s/,/ /g"); do echo -n " --exclude" $file; done))
TTL=${TTL:-1200}

LOCKFILE=$SYNC_FROM/.lock

while true
do
sleep 1

if [ $(find $SYNC_FROM -type f -name $TRIGGER_FILE* | wc -l) -gt 0 ]; then
        file=$(find $SYNC_FROM -type f -name $TRIGGER_FILE* -exec basename {} \;)
	echo "Got... $file"
        NOW=$(date +"%m-%d-%Y-%T")

        if (set -o noclobber; echo "$$" > "$LOCKFILE") 2> /dev/null;
        then
                trap 'rm -f "$LOCKFILE"; exit $?' INT TERM EXIT
                echo "Syncing & Cleaning deploy file... $NOW"
                echo "Running S3 Sync.." && /usr/local/bin/aws s3 sync ${SYNC_FROM} s3://${BUCKET}/ ${OMMIT_FILES} $(echo $(if [[ $file = ${TRIGGER_FILE}_single ]]; then echo ${PARAMS}; else echo ${PARAMS_FULL};fi)) \
		&& echo "Deleting files.." && find ${SYNC_FROM} -mindepth 1 -delete \
                && echo "Running Invalidation on ${DISTRIBUTION_ID}.." && /usr/local/bin/aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths "/*"
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
