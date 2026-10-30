#!/usr/bin/env bash
# Instala Git, Docker, Java, Semgrep, OWASP Dependency-Check y OWASP ZAP en Ubuntu 22.04/24.04.
set -euo pipefail

ZAP_VERSION="${ZAP_VERSION:-2.17.0}"
DC_VERSION="${DC_VERSION:-13.0.0}"
TOOLS_DIR="${TOOLS_DIR:-/opt/tools}"

echo "== Paquetes base =="
sudo apt-get update
sudo apt-get install -y git curl unzip ca-certificates openjdk-21-jre-headless python3-pip pipx

echo "== Docker Engine (script oficial) =="
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"   # cerrar sesión y volver a entrar para usar docker sin sudo
fi

echo "== Semgrep =="
pipx install semgrep || pipx upgrade semgrep
pipx ensurepath

echo "== OWASP Dependency-Check ${DC_VERSION} =="
sudo mkdir -p "$TOOLS_DIR" && sudo chown "$USER" "$TOOLS_DIR"
curl -fsSL -o /tmp/dc.zip "https://github.com/dependency-check/DependencyCheck/releases/download/v${DC_VERSION}/dependency-check-${DC_VERSION}-release.zip"
unzip -oq /tmp/dc.zip -d "$TOOLS_DIR"
sudo ln -sf "$TOOLS_DIR/dependency-check/bin/dependency-check.sh" /usr/local/bin/dependency-check

echo "== OWASP ZAP ${ZAP_VERSION} =="
curl -fsSL -o /tmp/zap.tar.gz "https://github.com/zaproxy/zaproxy/releases/download/v${ZAP_VERSION}/ZAP_${ZAP_VERSION}_Linux.tar.gz"
tar -xzf /tmp/zap.tar.gz -C "$TOOLS_DIR"
sudo ln -sf "$TOOLS_DIR/ZAP_${ZAP_VERSION}/zap.sh" /usr/local/bin/zap.sh

echo "Instalación terminada. Ejecute ./scripts/01-verificar-entorno.sh"
