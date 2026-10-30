# Política de mínimo privilegio para Way Créditos Lab:
# solo puede LEER su propio secreto de firma JWT.
path "secret/data/way-creditos-lab/jwt" {
  capabilities = ["read"]
}
