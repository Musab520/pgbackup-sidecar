#!/bin/bash
if [ "$DISABLE" != "true" ]; then
  set -o pipefail
  whoami;
  cd /opt/dumps;

  mkdir -p /opt/dumps/$POSTGRES_HOST;

  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  subject=$(echo "$TITLE - $timestamp")
  
  PGPASSWORD=$POSTGRES_PASSWORD pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER -p $POSTGRES_PORT --format=custom --clean --verbose --create --file /opt/dumps/${POSTGRES_HOST}/$(date -Iseconds).pgdump $POSTGRES_DB

  if [ $? -eq 0 ]; then
    echo "Dump executed successfully."
    if [ -n "$WEBHOOK_URL" ]; then
      curl -X POST "$WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "$(jo title="$(echo $subject)" description=@/var/log/cron.log status=Success)"
      if [ $? -ne 0 ]; then
        curl -X POST "$WEBHOOK_URL" \
              -H 'Content-Type: application/json' \
              -d "$(jo title="Failed Curl $(echo $subject)" description=@/var/log/cron.log status=Failure)"
      else
        echo "" > /var/log/cron.log
      fi
    fi
  else
    echo "Failed to Execute Dump"
    if [ -n "$WEBHOOK_URL" ]; then
        curl -X POST "$WEBHOOK_URL" \
              -H 'Content-Type: application/json' \
              -d "$(jo title="Failed $(echo $subject)" description=@/var/log/cron.log status=Failure)"
    fi
  fi

  current_date=$(date +%s);
  threshold_date_in_epoch=$(($current_date - $ROTATION_TIME));
  cd /opt/dumps/${POSTGRES_HOST}/;
  for file in *.pgdump; do
      file_date=$(echo "$file" | cut -d'.' -f1);
      file_date_in_epoch=$(date -d"$file_date" +%s);
      if [ "$file_date_in_epoch" -le "$threshold_date_in_epoch" ]; then
          echo "Deleting old backup: $file";
          rm -f $file;
      fi;
  done;


  cd /opt;

fi
