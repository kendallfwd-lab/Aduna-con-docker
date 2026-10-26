// Revisión estática rápida sin Docker ni conexión a Internet.
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const file = location => readFileSync(path.join(root, location), 'utf8');
const schema = file('database/01_schema.sql');
const seed = file('database/02_datos_demo.sql');
const views = file('database/03_vistas_seguridad.sql');
const workflow = JSON.parse(file('n8n/AGENTE_ADUANA_DEEPSEEK_CHAT.json'));

assert.equal((schema.match(/^CREATE TABLE /gm) ?? []).length, 10, 'deben existir 10 tablas');
assert.equal((views.match(/^CREATE VIEW /gm) ?? []).length, 5, 'deben existir 5 vistas de consulta');
assert.ok(views.includes('GRANT SELECT ON'), 'lector debe tener SELECT');
assert.ok(!views.includes('GRANT INSERT'), 'lector no debe tener INSERT');
assert.ok(schema.includes('FOREIGN KEY (contenedor_id, declaracion_id)'));

const segment = seed.split('INSERT INTO mercancias ')[1]?.split('INSERT INTO inspecciones ')[0] ?? '';
assert.equal((segment.match(/^ \(\d+,/gm) ?? []).length, 30, 'deben existir 30 líneas de mercancía');
const names = new Set(workflow.nodes.map(node => node.name));
assert.ok(names.has('Agente aduanero DeepSeek'));
assert.ok(names.has('DeepSeek Chat Model'));
assert.ok(names.has('Buscar_mercancias'));
for (const node of workflow.nodes) {
  if (node.type.includes('toolHttpRequest')) {
    assert.ok(node.parameters.url.startsWith('http://api:3000/api/'));
  }
}
assert.ok(existsSync(path.join(root, 'docs/GUIA_ESTUDIO_LAB3.pdf')));

console.log('PASS: 10 tablas, 5 vistas, 30 mercancías, credencial referenciada, flujo y PDF presentes.');
console.log('AVISO: esta comprobación es estática; para validar Docker/DeepSeek hay que arrancar los servicios.');
