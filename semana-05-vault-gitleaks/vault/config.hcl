# Configuración de HashiCorp Vault para el laboratorio (un solo nodo).
# En producción: TLS obligatorio, almacenamiento integrado (raft) y auto-unseal.
storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"   # solo laboratorio
}

api_addr      = "http://127.0.0.1:8200"
disable_mlock = true
ui            = false
