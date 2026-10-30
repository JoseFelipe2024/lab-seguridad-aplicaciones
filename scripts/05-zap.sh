#!/usr/bin/env bash
# DAST básico con OWASP ZAP: spider + escaneo activo ("quick scan") contra la app de laboratorio.
# Solo escanee aplicaciones propias o de laboratorio.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/evidencias/zap"
TARGET="${TARGET:-http://localhost:3000}"
mkdir -p "$OUT"

zap.sh -cmd -silent \
  -quickurl "$TARGET" \
  -quickprogress \
  -quickout "$OUT/zap-reporte.html"

echo "Reporte HTML: $OUT/zap-reporte.html"
