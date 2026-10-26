import http from 'node:http';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import pg from 'pg';
import { buildQuery, resumenSQL } from './queries.js';

const { Pool } = pg;
const port = Number(process.env.PORT || 3000);
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 8,
  connectionTimeoutMillis: 5000,
  idleTimeoutMillis: 30000
});
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../public');
const staticFiles = {
  '/': ['index.html', 'text/html; charset=utf-8'],
  '/styles.css': ['styles.css', 'text/css; charset=utf-8'],
  '/app.js': ['app.js', 'application/javascript; charset=utf-8']
};

const sendJSON = (res, status, payload) => {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
  res.end(JSON.stringify(payload));
};

const server = http.createServer(async (req, res) => {
  if (req.method !== 'GET') {
    return sendJSON(res, 405, { ok: false, mensaje: 'Solo se permite GET (lectura).' });
  }
  const url = new URL(req.url ?? '/', `http://${req.headers.host || 'localhost'}`);
  try {
    if (url.pathname === '/api/health') {
      await pool.query('SELECT 1');
      return sendJSON(res, 200, { ok: true, servicio: 'aduana-lab3', baseDeDatos: 'conectada' });
    }
    if (url.pathname === '/api/resumen') {
      const result = await pool.query(resumenSQL);
      return sendJSON(res, 200, { ok: true, datos: result.rows[0] });
    }
    const consulta = buildQuery(url.pathname, url.searchParams);
    if (consulta) {
      const result = await pool.query(consulta);
      return sendJSON(res, 200, { ok: true, total: result.rowCount, datos: result.rows });
    }
    if (Object.hasOwn(staticFiles, url.pathname)) {
      const [file, mime] = staticFiles[url.pathname];
      const content = await readFile(path.join(root, file));
      res.writeHead(200, {
        'Content-Type': mime,
        'Cache-Control': 'no-cache',
        'X-Content-Type-Options': 'nosniff',
        'Content-Security-Policy': "default-src 'self'; connect-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; base-uri 'none'; frame-ancestors 'none'"
      });
      return res.end(content);
    }
    return sendJSON(res, 404, { ok: false, mensaje: 'Ruta no encontrada' });
  } catch (error) {
    console.error('[api] Error de consulta:', error.message);
    return sendJSON(res, 503, { ok: false, mensaje: 'No fue posible consultar la base de datos.' });
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Aduana API lista en el puerto ${port}`);
});

const shutdown = () => {
  server.close(() => pool.end().then(() => process.exit(0)));
};
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

