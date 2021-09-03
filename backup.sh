#!/bin/bash
set -o pipefail
set -o errexit
set -o errtrace
set -o nounset
# set -o xtrace

JOB_NAME=${JOB_NAME:-cron-job-postgres}
BACKUP_DIR=${BACKUP_DIR:-/tmp}
#BOTO_CONFIG_PATH=${BOTO_CONFIG_PATH:-/root/.boto}
GCS_BUCKET=${GCS_BUCKET:-gs://postgres_data_jatin }
#GCS_KEY_FILE_PATH=${GCS_KEY_FILE_PATH:-}
POSTGRES_HOST=${POSTGRES_HOST:-localhost}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_DB=${POSTGRES_DB:-testdb}
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-}
#SLACK_ALERTS=${SLACK_ALERTS:-}
#SLACK_AUTHOR_NAME=${SLACK_AUTHOR_NAME:-postgres-gcs-backup}
#SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:-}
#SLACK_CHANNEL=${SLACK_CHANNEL:-}
#SLACK_USERNAME=${SLACK_USERNAME:-}
#SLACK_ICON=${SLACK_ICON:-}

backup() {
  mkdir -p $BACKUP_DIR
  date=$(date "+%Y-%m-%dT%H:%M:%SZ")
  archive_name="$date-$JOB_NAME-backup.sql.gz"
  cmd_auth_part=""
  if [[ ! -z $POSTGRES_USER ]] && [[ ! -z $POSTGRES_PASSWORD ]]
  then
    cmd_auth_part="--username=\"$POSTGRES_USER\" "
  fi

  cmd_db_part=""
  if [[ ! -z $POSTGRES_DB ]]
  then
    cmd_db_part="--db=\"$POSTGRES_DB\""
  fi

  export PGPASSWORD=$POSTGRES_PASSWORD
  cmd="pg_dump --host=\"$POSTGRES_HOST\" --port=\"$POSTGRES_PORT\" $cmd_auth_part $cmd_db_part | gzip > $BACKUP_DIR/$archive_name"
  echo "Starting to backup Postgres host=$POSTGRES_HOST port=$POSTGRES_PORT"

  eval "$cmd"
}

upload_to_gcs() {
  if [[ ! "$GCS_BUCKET" =~ gs://postgres_data_jatin ]]; then
    GCS_BUCKET="gs://${GCS_BUCKET}"
  fi

  echo "Uploading backup Archive to GCS bucket=$GCS_BUCKET"
  gsutil cp $BACKUP_DIR/$archive_name $GCS_BUCKET
}


err() {
  err_msg="${JOB_NAME} Something Went Wrong on line $(caller)"
  echo $err_msg >&2
}

cleanup() {
  rm $BACKUP_DIR/$archive_name
}

trap err ERR
backup
upload_to_gcs
cleanup
echo "Postgres-Backup done!"