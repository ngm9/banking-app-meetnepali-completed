#!/bin/bash
set -e

echo "[LOG] Stopping and removing containers..."
docker-compose -f /root/task/docker-compose.yml down --volumes --remove-orphans || true

echo "[LOG] Removing Postgres image..."
docker rmi -f postgres:15-alpine || true

echo "[LOG] Pruning Docker system..."
docker system prune -a --volumes -f

rm -rf /root/task/data/pgdata || true
rm -rf /root/task || true

echo "[INFO] Cleanup completed successfully! Droplet is now clean."