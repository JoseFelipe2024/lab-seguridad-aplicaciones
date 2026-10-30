#!/usr/bin/env bash
# Muestra la versión de cada componente del entorno de práctica.
set -uo pipefail

echo "== Sistema operativo =="; grep PRETTY_NAME /etc/os-release; uname -r
echo; echo "== Git =="; git --version
echo; echo "== Docker =="; docker version --format 'Cliente {{.Client.Version}} | Servidor {{.Server.Version}}'
echo; echo "== Java =="; java -version 2>&1 | grep -v JAVA_TOOL_OPTIONS | head -1
echo; echo "== Semgrep =="; semgrep --version
echo; echo "== OWASP Dependency-Check =="; dependency-check --version 2>/dev/null | grep -v JAVA_TOOL_OPTIONS
echo; echo "== OWASP ZAP =="; zap.sh -cmd -version 2>/dev/null | grep -v -e JAVA_TOOL_OPTIONS -e '^Found Java' -e '^Available memory' -e '^Using JVM' | tail -1
