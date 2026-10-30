#!/usr/bin/env bash
# Configura HashiCorp Vault para Way Créditos Lab:
#   1) inicia el servidor, 2) inicializa y abre (unseal) la bóveda,
#   3) habilita KV v2 y AppRole, 4) guarda el secreto JWT ROTADO,
#   5) crea la política de solo lectura y el AppRole de la aplicación.
# Las llaves de unseal y el token root quedan en .vault-init.json (excluido de Git).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export VAULT_ADDR="${VAULT_ADDR:-http://127.0.0.1:8200}"
mkdir -p /opt/vault/data

if ! curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1; then
  nohup vault server -config="$ROOT/vault/config.hcl" > /opt/vault/vault.log 2>&1 &
  until curl -s "$VAULT_ADDR/v1/sys/health" >/dev/null 2>&1; do sleep 1; done
fi

if [[ "$(vault status -format=json | jq -r .initialized)" != "true" ]]; then
  vault operator init -key-shares=1 -key-threshold=1 -format=json > "$ROOT/.vault-init.json"
  chmod 600 "$ROOT/.vault-init.json"
fi
vault operator unseal "$(jq -r '.unseal_keys_b64[0]' "$ROOT/.vault-init.json")" >/dev/null
export VAULT_TOKEN="$(jq -r .root_token "$ROOT/.vault-init.json")"

vault secrets list | grep -q '^secret/' || vault secrets enable -path=secret kv-v2
vault auth list | grep -q '^approle/' || vault auth enable approle

# Secreto NUEVO (rotado): el valor filtrado en Git queda invalidado.
vault kv put secret/way-creditos-lab/jwt signing_key="$(openssl rand -base64 48)"

vault policy write way-creditos-lab "$ROOT/vault/politica-way-app.hcl"
vault write auth/approle/role/way-creditos-lab token_policies=way-creditos-lab token_ttl=1h token_max_ttl=4h secret_id_ttl=24h

# Credenciales de la app (fuera de Git, solo para el contenedor)
{
  echo "VAULT_ROLE_ID=$(vault read -field=role_id auth/approle/role/way-creditos-lab/role-id)"
  echo "VAULT_SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/way-creditos-lab/secret-id)"
} > "$ROOT/.app-vault.env"
chmod 600 "$ROOT/.app-vault.env"
vault status | head -12
