#!/usr/bin/env bash
# Construye y levanta Way Créditos Lab en un contenedor aislado (puerto 3000).
set -euo pipefail
cd "$(dirname "$0")/../app"

BASE_IMAGE="${BASE_IMAGE:-node:22-bookworm-slim}"
docker build --build-arg BASE_IMAGE="$BASE_IMAGE" -t way-creditos-lab:1.0 .
docker rm -f way-lab >/dev/null 2>&1 || true
docker run -d --name way-lab -p 3000:3000 --memory 768m --pids-limit 200 --restart unless-stopped way-creditos-lab:1.0
sleep 3
docker ps --filter name=way-lab
curl -s http://localhost:3000/ | grep -o '<h1>.*</h1>'
