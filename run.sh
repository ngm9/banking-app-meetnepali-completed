#!/bin/bash
set -e

echo "[INFO] Starting banking DB environment..."
docker-compose -f /root/task/docker-compose.yml up -d

# Wait for PostgreSQL to be ready
for i in {1..30}; do
  if docker exec banking_db_pg pg_isready -U bank_app_user -d banking_db; then
    echo "[INFO] PostgreSQL is available."
    break
  fi
  sleep 2
done
if ! docker exec banking_db_pg pg_isready -U bank_app_user -d banking_db; then
  echo "[ERROR] PostgreSQL did not become available in time!"
  exit 1
fi

echo "[INFO] Database ready and accessible on port 5432."