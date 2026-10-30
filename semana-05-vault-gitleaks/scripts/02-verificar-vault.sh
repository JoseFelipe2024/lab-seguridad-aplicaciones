#!/usr/bin/env bash
# Verifica que Way Créditos Lab recupere el secreto JWT desde Vault:
#   1) levanta el contenedor con credenciales AppRole (sin secreto JWT en el entorno),
#   2) consulta /api/salud, 3) inicia sesión y valida la firma del JWT
#   contra el secreto de Vault y contra el secreto filtrado (debe fallar).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
export VAULT_TOKEN="$(jq -r .root_token "$ROOT/.vault-init.json")"

docker image inspect way-creditos-lab:1.1 >/dev/null 2>&1 || docker build -t way-creditos-lab:1.1 "$ROOT/app"
docker rm -f way-lab >/dev/null 2>&1 || true
docker run -d --name way-lab -p 3000:3000 --memory 768m --pids-limit 200 \
  --add-host host.docker.internal:host-gateway \
  -e VAULT_ADDR=http://host.docker.internal:8200 \
  --env-file "$ROOT/.app-vault.env" way-creditos-lab:1.1 >/dev/null
until curl -s http://localhost:3000/api/salud >/dev/null 2>&1; do sleep 1; done

echo "== Log de arranque de la aplicación =="
docker logs way-lab
echo; echo "== GET /api/salud =="
curl -s http://localhost:3000/api/salud; echo

echo; echo "== Login y validación de la firma del JWT =="
TOKEN=$(curl -s -c - -d "usuario=admin&clave=admin123" http://localhost:3000/login | awk '/session/{print $7}')
SECRETO=$(vault kv get -field=signing_key secret/way-creditos-lab/jwt)
FILTRADO="${SECRETO_FILTRADO:-}"
docker run --rm -e T="$TOKEN" -e S="$SECRETO" -e F="$FILTRADO" -w /app way-creditos-lab:1.1 node -e '
const jwt = require("jsonwebtoken");
try { const p = jwt.verify(process.env.T, process.env.S); console.log("Firma con secreto de Vault  -> VÁLIDA (usuario:", p.usuario + ")"); }
catch (e) { console.log("Firma con secreto de Vault  -> INVÁLIDA:", e.message); }
if (process.env.F) {
  try { jwt.verify(process.env.T, process.env.F); console.log("Firma con secreto filtrado  -> VÁLIDA (¡riesgo!)"); }
  catch (e) { console.log("Firma con secreto filtrado  -> RECHAZADA (" + e.message + ")"); }
}'
