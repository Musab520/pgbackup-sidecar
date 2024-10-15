#!/bin/bash
sleep 60;

PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -d $POSTGRES_DB -U $POSTGRES_USER -p $POSTGRES_PORT -v ON_ERROR_STOP=1 -c "SELECT 1;"

envsubst '${CRON_TIME}' < /opt/crontab > /opt/scripts/crontab

envsubst '${POSTGRES_USER} ${POSTGRES_PASSWORD} ${POSTGRES_DB} ${POSTGRES_HOST} ${POSTGRES_PORT} ${WEBHOOK_URL} ${DISABLE}' < /opt/backup.sh > /opt/scripts/backup.sh

chmod +x /opt/scripts/backup.sh;

echo "Cron starting";

crontab -u root /opt/scripts/crontab;

crond -f -L /var/log/cron.log & tail -f /var/log/cron.log;