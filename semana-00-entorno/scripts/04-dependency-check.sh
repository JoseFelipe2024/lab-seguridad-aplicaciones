#!/usr/bin/env bash
# SCA con OWASP Dependency-Check sobre las dependencias npm de app/.
# Requiere una clave gratuita del NVD (https://nvd.nist.gov/developers/request-an-api-key) en NVD_API_KEY,
# o bien un espejo del data feed NVD 2.0 en NVD_DATAFEED (ej. http://localhost:8000/).
# La primera ejecución descarga toda la base de CVE (10-30 min); las siguientes son incrementales.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/evidencias/dependency-check"
DATA="${DC_DATA:-$ROOT/.dc-data}"
mkdir -p "$OUT" "$DATA"

FUENTE=()
if [[ -n "${NVD_DATAFEED:-}" ]]; then
  FUENTE=(--nvdDatafeed "$NVD_DATAFEED")
elif [[ -n "${NVD_API_KEY:-}" ]]; then
  FUENTE=(--nvdApiKey "$NVD_API_KEY")
fi

dependency-check \
  --project "Way Creditos Lab" \
  --scan "$ROOT/app" \
  --exclude "**/node_modules/**" \
  --data "$DATA" \
  "${FUENTE[@]}" ${DC_EXTRA_ARGS:-} \
  --disableOssIndex --disableCentral \
  --format HTML --format JSON --format CSV \
  --out "$OUT"

echo "Reportes en $OUT"
