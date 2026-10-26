// Ejecutar SOLO dentro del contenedor de n8n, después de crear el usuario dueño.
// No registra ni imprime la clave API. Importa credencial cifrada en n8n y el workflow.
import { writeFileSync, unlinkSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

const apiKey = (process.env.DEEPSEEK_API_KEY ?? '').trim();
if (!apiKey || apiKey.includes('PEGA_AQUI') || apiKey.length < 12) {
  console.error('ERROR: Edita .env y pega tu DEEPSEEK_API_KEY válida antes de provisionar.');
  process.exit(1);
}
const temp = `/tmp/aduana-credenciales-${process.pid}.json`;
const credentials = [{
  id: 'lab3-deepseek-cred',
  name: 'DeepSeek Laboratorio 3',
  type: 'deepSeekApi',
  data: { apiKey }
}];

// Importar dentro del proyecto personal del usuario que acaba de crear su cuenta.
// CLI 2.x permite --userId. Si la imagen cambia su almacenamiento, el CLI
// aplicará su asignación predeterminada y el README incluye importación manual.
let ownerArgs = [];
let credentialExists = false;
let workflowExists = false;
try {
  const { DatabaseSync } = await import('node:sqlite');
  const db = new DatabaseSync('/home/node/.n8n/database.sqlite', { readOnly: true });
  const owner = db.prepare('SELECT id FROM "user" ORDER BY "createdAt" ASC LIMIT 1').get();
  credentialExists = Boolean(db.prepare('SELECT id FROM credentials_entity WHERE id = ?').get('lab3-deepseek-cred'));
  workflowExists = Boolean(db.prepare('SELECT id FROM workflow_entity WHERE id = ?').get('c6b753dd-17bf-43b7-96b4-01cb9de83000'));
  db.close();
  if (owner?.id) ownerArgs = [`--userId=${owner.id}`];
} catch {
  console.warn('No fue posible detectar el usuario dueño; se usará la asignación predeterminada de n8n.');
}

try {
  if (!credentialExists) {
    writeFileSync(temp, JSON.stringify(credentials), { mode: 0o600 });
    execFileSync('n8n', ['import:credentials', `--input=${temp}`, ...ownerArgs], { stdio: 'inherit' });
  } else {
    console.log('La credencial DeepSeek ya existe; se conserva sin cambios.');
  }
  if (!workflowExists) {
    execFileSync('n8n', ['import:workflow', '--input=/plantillas/AGENTE_ADUANA_DEEPSEEK_CHAT.json', ...ownerArgs], { stdio: 'inherit' });
  } else {
    console.log('El workflow del laboratorio ya existe; se conserva sin cambios.');
  }
  console.log('Importación completada. Reinicia n8n para recargar el flujo.');
} finally {
  try { unlinkSync(temp); } catch { /* no existe */ }
}
