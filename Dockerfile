FROM postgres:15-alpine

RUN apk add --update --no-cache bash gzip coreutils curl envsubst jo
RUN apk add --update busybox-suid

ENV POSTGRES_USER=user
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_DB=dbname
ENV POSTGRES_HOST=aqua
ENV CRON_TIME="0 0 * * *"
ENV POSTGRES_PORT=5432
ENV ROTATION_TIME=180

WORKDIR /opt

RUN mkdir -p /opt/dumps /opt/scripts
RUN chmod -R 777 /opt/dumps
RUN chmod -R 777 /opt/scripts
RUN chmod -R 777 /var/log
RUN chown root:root /opt/dumps /opt/scripts

COPY backup.sh /opt/backup.sh

COPY crontab /opt/crontab

COPY entrypoint.sh /opt/scripts/entrypoint.sh
RUN chmod +x /opt/scripts/entrypoint.sh

RUN touch /var/log/cron.log
RUN chmod -R 777 /var/log

RUN echo -e "root\npostgres" > /etc/cron.allow

ENTRYPOINT ["sh", "-c", "/opt/scripts/entrypoint.sh;"]