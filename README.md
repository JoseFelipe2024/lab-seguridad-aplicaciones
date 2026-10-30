# Laboratorio de Seguridad en Aplicaciones — UMG

Repositorio de práctica de **José Daniel Felipe Calderón** (carné 1493-19-7376) para el curso **Seguridad en Aplicaciones**, Maestría en Seguridad de Sistemas, Universidad Mariano Gálvez de Guatemala.

Cada tarea del curso vive en **su propia carpeta**, con su código, sus scripts, sus evidencias y su README. Cada entrega también está marcada con una etiqueta de Git (`git checkout semana-XX`).

| Carpeta | Tarea | Herramientas | Etiqueta |
|---|---|---|---|
| [`semana-00-entorno/`](semana-00-entorno/) | Configuración del entorno de práctica | Git, Docker, Semgrep, OWASP Dependency-Check, OWASP ZAP | `semana-00` |
| [`semana-05-vault-gitleaks/`](semana-05-vault-gitleaks/) | Gestión de secretos y detección de fugas | HashiCorp Vault, Gitleaks | `semana-05` |

La aplicación de laboratorio es **Way Créditos Lab**: un módulo en Node.js que simula la consulta de clientes y cuotas de una empresa de ventas al crédito. Es **intencionalmente vulnerable**, así que se ejecuta solo dentro de Docker.

## Archivos comunes

- `.gitleaks.toml`: configuración de Gitleaks para todo el repositorio (reglas por defecto y exclusión de reportes generados).
- `.gitleaksignore`: hallazgos ya revisados y remediados.
- `.gitignore`: excluye dependencias, bases locales y credenciales de Vault.
