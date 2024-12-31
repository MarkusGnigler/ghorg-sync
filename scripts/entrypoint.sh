#!/bin/bash

CRON_CONFIG_FILE="${HOME}/crontabs"

# create crontab job
CRON_SCHEDULE="${CRON_SCHEDULE:-* * * * *}"
CRON_COMMAND="${CRON_COMMAND:-/app/sync.sh}"
echo "$CRON_SCHEDULE $CRON_COMMAND >> /dev/stdout 2>&1" > $CRON_CONFIG_FILE  # /etc/crontabs/root

# exec "$@"
# foreground run crond
supercronic -passthrough-logs -quiet "${CRON_CONFIG_FILE}"