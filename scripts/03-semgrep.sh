#!/usr/bin/env bash
# SAST con Semgrep sobre el código de app/.
# Por defecto usa los paquetes del registro (p/javascript, p/nodejs, p/secrets).
# Si SEMGREP_RULES apunta a una carpeta local de reglas (clon de semgrep/semgrep-rules), usa esa.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/evidencias/semgrep"
mkdir -p "$OUT"

if [[ -n "${SEMGREP_RULES:-}" ]]; then
  CONFIG=(--config "$SEMGREP_RULES")
else
  CONFIG=(--config p/javascript --config p/nodejs --config p/secrets)
fi

cd "$ROOT"
semgrep scan "${CONFIG[@]}" --metrics=off --exclude node_modules \
  --json-output="$OUT/semgrep-resultados.json" \
  --sarif-output="$OUT/semgrep-resultados.sarif" \
  --text-output="$OUT/semgrep-resultados.txt" \
  app/
