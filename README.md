# pgbackup-sidecar

`pgbackup-sidecar` is a lightweight Docker sidecar container designed to automate regular backups of a PostgreSQL database using `pg_dump`. The container runs a cron job that periodically dumps the database and stores the backups to a backup directory of your choice and even optionally send logs to a webhook. Currently working on backing up to S3 and other versions of postgres and adding more advanced options for pg_dump.

## Features

- Automated PostgreSQL backups using `pg_dump`.
- Configurable backup schedule with `crontab`.
- Optionally send logs to a webhook

## Prerequisites

- Docker
- A running PostgreSQL container
- Access to the PostgreSQL database

## Getting Started

### 1. Running the Demo

```bash
git clone git@github.com:Musab520/pgbackup-sidecar.git
make sidecar-stack
make run-sidecar-stack
docker logs -f dev-pgbackup-1
```

### 2. Configure Environment Variables
| Variable              | Description                                                                 |
| --------------------- | --------------------------------------------------------------------------- |
| `POSTGRES_HOST`             | Hostname of the PostgreSQL server.                                           |
| `POSTGRES_PORT`             | Port number of the PostgreSQL server (default: `5432`).                      |
| `POSTGRES_USER`             | Username for the PostgreSQL database.                                        |
| `POSTGRES_PASSWORD`         | Password for the PostgreSQL user.                                            |
| `POSTGRES_DB`         | Name of the PostgreSQL database to back up.                                  |
| `CRON_TIME`       | Cron schedule string for backup frequency (e.g., `"0 2 * * *"` for daily at 2AM). |
| `ROTATION_TIME`           | Seconds in epoch for how the time interval the backups should be maintained (e.g., 86400 for 24 hours) |
| `WEBHOOK_URL`           | Sends a json body of title and description(logs) to a webhook provided (optional) |
| `TITLE`           | Sets the title for whats being sent with the Webhook URL (optional) |
| `DISABLE`         | disbales script (optional) |

