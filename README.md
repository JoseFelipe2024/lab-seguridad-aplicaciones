# Laboratorio de Seguridad en Aplicaciones — UMG

Repositorio de práctica de José Daniel Felipe Calderón para el curso **Seguridad en Aplicaciones** (Maestría en Seguridad de Sistemas, Universidad Mariano Gálvez de Guatemala).

Aquí se guardan el código de laboratorio, las configuraciones y las evidencias de cada herramienta del curso.

> ⚠️ `app/` contiene una aplicación **intencionalmente vulnerable** (Way Créditos Lab). Ejecútela solo dentro de Docker y nunca la exponga a Internet.

## Estructura

```
lab-seguridad-aplicaciones/
├── app/                       # Way Créditos Lab (Node.js + Express) y su Dockerfile
├── scripts/                   # Scripts de instalación y ejecución de cada herramienta
│   ├── 00-instalar-herramientas.sh
│   ├── 01-verificar-entorno.sh
│   ├── 02-levantar-app.sh
│   ├── 03-semgrep.sh          # SAST
│   ├── 04-dependency-check.sh # SCA
│   └── 05-zap.sh              # DAST
└── evidencias/                # Reportes generados (JSON, HTML, TXT) y capturas
    ├── semgrep/
    ├── dependency-check/
    ├── zap/
    └── capturas/
```

## Herramientas del entorno

| Componente | Uso en el curso |
|---|---|
| Git | Control de versiones del código, configuraciones y evidencias |
| Docker | Ejecutar la aplicación de laboratorio y herramientas de forma aislada |
| Semgrep | Análisis estático (SAST) del código fuente |
| OWASP Dependency-Check | Análisis de componentes (SCA) contra la base de CVE del NVD |
| OWASP ZAP | Análisis dinámico (DAST) contra la aplicación en ejecución |

## Uso rápido

```bash
./scripts/00-instalar-herramientas.sh   # una sola vez (Ubuntu 22.04/24.04)
./scripts/01-verificar-entorno.sh
./scripts/02-levantar-app.sh            # http://localhost:3000
./scripts/03-semgrep.sh
NVD_API_KEY=<su-clave> ./scripts/04-dependency-check.sh
./scripts/05-zap.sh
git add evidencias && git commit -m "Evidencias de laboratorio"
```

Las vulnerabilidades sembradas en `app/server.js` están marcadas con comentarios `[VULN]` (inyección SQL, XSS reflejado, inyección de comandos, `eval`, secretos embebidos, cookies inseguras y prototype pollution). Las dependencias de `app/package.json` están fijadas en versiones con CVE conocidos a propósito.
