# Semana 0 — Configuración del entorno de práctica

**Tarea:** configurar un entorno de práctica con un repositorio Git, Docker, Semgrep (SAST), OWASP Dependency-Check (SCA) y OWASP ZAP (DAST), y documentar la instalación y la ejecución de cada herramienta.

> ⚠️ `app/` contiene **Way Créditos Lab**, una aplicación **intencionalmente vulnerable**. Ejecútela solo dentro de Docker y nunca la exponga a Internet.

## Estructura

```
semana-00-entorno/
├── app/                       # Way Créditos Lab (Node.js + Express) y su Dockerfile
├── scripts/
│   ├── 00-instalar-herramientas.sh
│   ├── 01-verificar-entorno.sh
│   ├── 02-levantar-app.sh
│   ├── 03-semgrep.sh          # SAST
│   ├── 04-dependency-check.sh # SCA
│   └── 05-zap.sh              # DAST
└── evidencias/                # reportes (JSON, HTML, SARIF, CSV) y capturas
    ├── semgrep/
    ├── dependency-check/
    ├── zap/
    └── capturas/
```

## Resultados

| Herramienta | Resultado |
|---|---|
| Semgrep 1.183.0 | 22 hallazgos (394 reglas) |
| Dependency-Check 13.0.0 | 12 dependencias vulnerables, 94 vulnerabilidades |
| OWASP ZAP 2.17.0 | 12 tipos de alerta, 4 de riesgo alto |

## Uso

Ejecutar desde esta carpeta (`cd semana-00-entorno`):

```bash
./scripts/00-instalar-herramientas.sh   # una sola vez (Ubuntu 22.04/24.04)
./scripts/01-verificar-entorno.sh
./scripts/02-levantar-app.sh            # http://localhost:3000
./scripts/03-semgrep.sh
NVD_API_KEY=<su-clave> ./scripts/04-dependency-check.sh
./scripts/05-zap.sh
```

Las vulnerabilidades sembradas en `app/server.js` están marcadas con comentarios `[VULN]`. Las dependencias de `app/package.json` están fijadas a propósito en versiones con CVE conocidos.
