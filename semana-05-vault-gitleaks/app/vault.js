// Cliente mínimo de HashiCorp Vault (API HTTP) para Way Créditos Lab.
// La aplicación se autentica con AppRole y lee el secreto de firma JWT
// desde el motor KV versión 2. Ningún secreto queda escrito en el código.

const VAULT_ADDR = process.env.VAULT_ADDR || "http://127.0.0.1:8200";

async function vaultRequest(method, path, token, body) {
  const res = await fetch(`${VAULT_ADDR}/v1/${path}`, {
    method,
    headers: { "Content-Type": "application/json", ...(token ? { "X-Vault-Token": token } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  if (!res.ok) {
    throw new Error(`Vault respondió ${res.status} en ${path}`);
  }
  return res.json();
}

// Inicia sesión con AppRole (role_id + secret_id) y devuelve un token de corta duración.
async function loginAppRole() {
  const roleId = process.env.VAULT_ROLE_ID;
  const secretId = process.env.VAULT_SECRET_ID;
  if (!roleId || !secretId) {
    throw new Error("Faltan VAULT_ROLE_ID / VAULT_SECRET_ID en el entorno");
  }
  const data = await vaultRequest("POST", "auth/approle/login", null, { role_id: roleId, secret_id: secretId });
  return data.auth.client_token;
}

// Lee el secreto de firma JWT desde secret/data/way-creditos-lab/jwt (KV v2).
async function cargarSecretoJwt() {
  const token = await loginAppRole();
  const data = await vaultRequest("GET", "secret/data/way-creditos-lab/jwt", token);
  const valor = data.data.data.signing_key;
  if (!valor) throw new Error("El secreto signing_key no existe en Vault");
  return { valor, version: data.data.metadata.version };
}

module.exports = { cargarSecretoJwt, VAULT_ADDR };
