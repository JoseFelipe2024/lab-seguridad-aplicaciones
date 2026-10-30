// Way Créditos Lab — aplicación INTENCIONALMENTE VULNERABLE para prácticas de SAST/DAST.
// Simula un módulo de consulta de clientes y cuotas de una empresa de ventas al crédito.
// Solo debe ejecutarse dentro del contenedor de laboratorio.

const express = require("express");
const cookieParser = require("cookie-parser");
const jwt = require("jsonwebtoken");
const { exec } = require("child_process");
const _ = require("lodash");
const moment = require("moment");
const initSqlJs = require("sql.js");

const app = express();
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(cookieParser());

// Remediación CWE-798: el secreto de firma JWT ya no está en el código.
// Se recupera de HashiCorp Vault (AppRole + KV v2) al iniciar la aplicación.
const { cargarSecretoJwt, VAULT_ADDR } = require("./vault");
let JWT_SECRET = null;
let JWT_SECRET_VERSION = null;

let db;

function layout(title, body) {
  return `<!DOCTYPE html><html lang="es"><head><meta charset="utf-8"><title>${title}</title></head>
<body style="font-family:sans-serif;max-width:760px;margin:30px auto">
<h1>Way Créditos Lab</h1>
<nav><a href="/">Inicio</a> | <a href="/clientes">Clientes</a> | <a href="/buscar?q=">Buscar</a> |
<a href="/login">Ingresar</a> | <a href="/diagnostico">Diagnóstico de red</a> | <a href="/api/cuotas?cliente=1">API cuotas</a></nav>
<hr>${body}</body></html>`;
}

app.get("/", (req, res) => {
  res.send(layout("Inicio", `<p>Sistema de laboratorio para consulta de clientes, créditos y cuotas.</p>
  <p>Fecha del servidor: ${moment().format("DD/MM/YYYY HH:mm")}</p>`));
});

// [VULN] Inyección SQL: concatenación directa del parámetro (CWE-89)
app.get("/clientes", (req, res) => {
  const sucursal = req.query.sucursal || "Zona 11";
  const sql = "SELECT id, nombre, sucursal, saldo FROM clientes WHERE sucursal = '" + sucursal + "'";
  try {
    const result = db.exec(sql);
    const rows = result.length ? result[0].values : [];
    const html = rows.map(r => `<tr><td>${r[0]}</td><td>${r[1]}</td><td>${r[2]}</td><td>Q${r[3]}</td></tr>`).join("");
    res.send(layout("Clientes", `<form action="/clientes"><label>Sucursal <input name="sucursal" value="${sucursal}"></label>
    <button>Filtrar</button></form><table border="1" cellpadding="4"><tr><th>ID</th><th>Nombre</th><th>Sucursal</th><th>Saldo</th></tr>${html}</table>`));
  } catch (e) {
    // [VULN] Exposición de detalles de error (CWE-209)
    res.status(500).send(layout("Error", `<pre>Error SQL: ${e.message}\n${sql}</pre>`));
  }
});

// [VULN] XSS reflejado: el término se devuelve sin codificar (CWE-79)
app.get("/buscar", (req, res) => {
  const q = req.query.q || "";
  res.send(layout("Buscar", `<form action="/buscar"><input name="q" value=""><button>Buscar</button></form>
  <p>Resultados para: ${q}</p>`));
});

app.get("/login", (req, res) => {
  res.send(layout("Ingresar", `<form method="POST" action="/login">
  <label>Usuario <input name="usuario"></label> <label>Clave <input name="clave" type="password"></label>
  <button>Ingresar</button></form>`));
});

app.post("/login", (req, res) => {
  const { usuario, clave } = req.body;
  // [VULN] Credenciales por defecto embebidas (CWE-798)
  if (usuario === "admin" && clave === "admin123") {
    const token = jwt.sign({ usuario, rol: "admin" }, JWT_SECRET);
    // [VULN] Cookie sin HttpOnly / Secure / SameSite (CWE-1004, CWE-614)
    res.cookie("session", token);
    return res.send(layout("Bienvenido", `<p>Bienvenido ${usuario}</p>`));
  }
  res.status(401).send(layout("Ingresar", `<p>Usuario o clave incorrectos para ${usuario}</p>`));
});

// [VULN] Inyección de comandos del sistema operativo (CWE-78)
app.get("/diagnostico", (req, res) => {
  const host = req.query.host;
  if (!host) {
    return res.send(layout("Diagnóstico", `<form action="/diagnostico"><label>Host de sucursal <input name="host" value="127.0.0.1"></label>
    <button>Probar</button></form>`));
  }
  exec("ping -c 1 " + host, { timeout: 15000 }, (err, stdout, stderr) => {
    res.send(layout("Diagnóstico", `<pre>${stdout}${stderr}</pre>`));
  });
});

// [VULN] Uso de eval sobre datos del usuario (CWE-95)
app.get("/api/cuotas", (req, res) => {
  const cliente = req.query.cliente || "1";
  const plazo = req.query.plazo || "12";
  const meses = eval(plazo);
  const r = db.exec("SELECT saldo FROM clientes WHERE id = " + cliente);
  const saldo = r.length ? r[0].values[0][0] : 0;
  const cuota = _.round(saldo / meses, 2);
  res.json({ cliente, plazo: meses, cuota, generado: moment().toISOString() });
});

// [VULN] Prototype pollution vía lodash.merge con entrada del usuario (CWE-1321)
app.post("/api/preferencias", (req, res) => {
  const prefs = _.merge({}, req.body);
  res.json({ ok: true, prefs });
});

// Estado del secreto: confirma su origen sin revelar el valor.
app.get("/api/salud", (req, res) => {
  res.json({ estado: "ok", secreto_jwt: { origen: "HashiCorp Vault", ruta: "secret/way-creditos-lab/jwt", version: JWT_SECRET_VERSION, cargado: !!JWT_SECRET } });
});

async function iniciar() {
  try {
    const s = await cargarSecretoJwt();
    JWT_SECRET = s.valor;
    JWT_SECRET_VERSION = s.version;
    console.log(`Secreto JWT recuperado desde Vault (${VAULT_ADDR}), versión ${s.version}`);
  } catch (e) {
    // Sin secreto no hay arranque: no existe un valor de respaldo en el código.
    console.error(`No se pudo obtener el secreto desde Vault: ${e.message}`);
    process.exit(1);
  }
  const SQL = await initSqlJs();
  db = new SQL.Database();
  db.run(`CREATE TABLE clientes (id INTEGER PRIMARY KEY, nombre TEXT, sucursal TEXT, saldo REAL);
          INSERT INTO clientes VALUES (1,'María López','Zona 11',4500.00),(2,'Carlos Pérez','Zona 11',1200.50),
          (3,'Ana García','Villa Nueva',8900.00),(4,'Luis Méndez','Chiquimula',3100.75);
          CREATE TABLE usuarios (id INTEGER PRIMARY KEY, usuario TEXT, clave TEXT);
          INSERT INTO usuarios VALUES (1,'admin','admin123');`);
  const port = process.env.PORT || 3000;
  app.listen(port, () => console.log(`Way Créditos Lab escuchando en http://0.0.0.0:${port}`));
}

iniciar();
