# Semana 5 — Gestión de secretos con HashiCorp Vault y detección de fugas con Gitleaks

**Tarea:** configurar HashiCorp Vault para almacenar un secreto que inicialmente se encuentra en el código fuente y utilizar Gitleaks para detectar credenciales expuestas en el repositorio y en el historial de Git. Retirar el secreto del código, almacenarlo en la bóveda, verificar su recuperación desde la aplicación y documentar la detección y la remediación de la fuga.

Punto de partida: una copia de Way Créditos Lab de la Semana 0.

## Estructura

```
semana-05-vault-gitleaks/
├── app/                        # Way Créditos Lab; app/vault.js lee el secreto desde Vault
├── vault/
│   ├── config.hcl              # servidor Vault del laboratorio (almacenamiento en archivo)
│   └── politica-way-app.hcl    # política de solo lectura del secreto JWT
├── scripts/
│   ├── 01-configurar-vault.sh  # init/unseal, KV v2, AppRole, secreto rotado y política
│   └── 02-verificar-vault.sh   # levanta la app y valida la firma JWT con el secreto de Vault
└── evidencias/
    ├── gitleaks/               # 01 = detección, 02 = escaneo después de la remediación
    └── capturas/
```

## Historia de la fuga en Git

| Commit | Etapa |
|---|---|
| `7edb73a` | **Fuga:** el secreto JWT queda escrito en `app/server.js`, línea 19 |
| `a4fb403` | **Detección:** Gitleaks lo encuentra en el historial (`generic-api-key`) |
| `ffdf5c0` | **Remediación:** el secreto se retira del código y la app lo lee desde Vault (AppRole + KV v2) |
| siguiente | **Cierre:** el secreto se rotó, el hallazgo queda en `.gitleaksignore` y el re-escaneo termina en *no leaks found* |

## Uso

```bash
cd semana-05-vault-gitleaks
./scripts/01-configurar-vault.sh      # requiere vault, jq y openssl
SECRETO_FILTRADO=<valor_detectado> ./scripts/02-verificar-vault.sh
gitleaks git ..                       # desde la raíz del repositorio usa .gitleaks.toml y .gitleaksignore
```

Las llaves de unseal, el token root (`.vault-init.json`) y las credenciales del AppRole (`.app-vault.env`) se crean en esta carpeta y están excluidos de Git.
