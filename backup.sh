#!/bin/bash
whoami;
cd /opt/dumps;
mkdir -p /opt/dumps/$POSTGRES_HOST;
PGPASSWORD=$POSTGRES_PASSWORD pg_dumpall -h $POSTGRES_HOST -U $POSTGRES_USER -p $POSTGRES_PORT -c -v --if-exists | gzip > /opt/dumps/${POSTGRES_HOST}/$(date -Iseconds).sql.gz;

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
subject=$(echo "$TITLE - $timestamp")

if [ $? -eq 0 ]; then
  echo "Dump executed successfully."
  if [ -n "$WEBHOOK_URL" ]; then
    curl -X POST "$WEBHOOK_URL" \
      -H 'Content-Type: application/json' \
      -d "$(jo title="$(echo $subject)" description=@/var/log/cron.log)"
    if [ $? -ne 0 ]; then
      curl -X POST "$WEBHOOK_URL" \
            -H 'Content-Type: application/json' \
            -d "$(jo title="Failed Curl $(echo $subject)" description=@/var/log/cron.log)"
    else
      echo "" > /var/log/cron.log
    fi
  fi
else
  echo "Failed to Execute Dump"
  if [ -n "$WEBHOOK_URL" ]; then
      curl -X POST "$WEBHOOK_URL" \
            -H 'Content-Type: application/json' \
            -d "$(jo title="Failed $(echo $subject)" description=@/var/log/cron.log)"
  fi
fi

current_date=$(date +%s);
threshold_date_in_epoch=$(($current_date - $ROTATION_TIME));
cd /opt/dumps/${POSTGRES_HOST}/;
for file in *.sql.gz; do
    file_date=$(echo "$file" | cut -d'.' -f1);
    file_date_in_epoch=$(date -d"$file_date" +%s);
    if [ "$file_date_in_epoch" -le "$threshold_date_in_epoch" ]; then
        echo "Deleting old backup: $file";
        rm -f $file;
    fi;
done;
cd /opt;
