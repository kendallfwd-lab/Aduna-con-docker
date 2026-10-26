const byId = id => document.getElementById(id);
const number = new Intl.NumberFormat('es-CR');
const status = { RETENIDA: 'Retenida', LIBERADA: 'Liberada', EN_DEPOSITO: 'En depósito', EN_INSPECCION: 'En inspección' };

async function getJSON(path) {
  const response = await fetch(path);
  if (!response.ok) throw new Error(`HTTP ${response.status}`);
  const json = await response.json();
  if (!json.ok) throw new Error(json.mensaje || 'Consulta fallida');
  return json;
}

async function loadSummary() {
  try {
    const result = await getJSON('/api/resumen');
    byId('kpi-total').textContent = number.format(result.datos.total_lineas);
    byId('kpi-unidades').textContent = number.format(result.datos.total_unidades);
    byId('kpi-retenidas').textContent = number.format(result.datos.retenidas);
    byId('kpi-liberadas').textContent = number.format(result.datos.liberadas);
    byId('conexion').textContent = '● PostgreSQL conectado';
    byId('conexion').classList.remove('off');
  } catch {
    byId('conexion').textContent = '● Sin conexión a PostgreSQL';
    byId('conexion').classList.add('off');
  }
}

function td(text, className = '') {
  const cell = document.createElement('td');
  cell.textContent = text === undefined || text === null ? '—' : String(text);
  if (className) cell.className = className;
  return cell;
}

async function loadInventory() {
  const params = new URLSearchParams({
    pais: byId('pais').value,
    bodega: byId('bodega').value,
    estado: byId('estado').value,
    limit: '100'
  });
  const body = byId('filas');
  body.replaceChildren();
  byId('contador').textContent = 'Consultando…';
  try {
    const result = await getJSON(`/api/mercancias?${params}`);
    byId('contador').textContent = `${result.total} resultados`;
    if (!result.datos.length) {
      const row = document.createElement('tr');
      const cell = td('No encontramos mercancías con esos filtros.');
      cell.colSpan = 6;
      row.append(cell);
      body.append(row);
      return;
    }
    result.datos.forEach(item => {
      const row = document.createElement('tr');
      row.append(td(item.mercancia),td(item.pais_origen),td(item.bodega),td(number.format(item.cantidad)));
      const state = document.createElement('td');
      const badge = document.createElement('span');
      badge.className = `pill ${item.estado}`;
      badge.textContent = status[item.estado] || item.estado;
      state.append(badge);
      row.append(state, td(item.declaracion));
      body.append(row);
    });
  } catch {
    byId('contador').textContent = 'Error de conexión';
    const row = document.createElement('tr');
    const cell = td('No se pudo consultar la base de datos. Revisa docker compose logs api.');
    cell.colSpan = 6;
    row.append(cell);
    body.append(row);
  }
}

byId('filtros').addEventListener('submit', event => {
  event.preventDefault();
  loadInventory();
});
byId('ejemplo').addEventListener('click', () => {
  byId('pais').value = 'China';
  byId('bodega').value = 'Bodega 2';
  byId('estado').value = 'RETENIDA';
  loadInventory();
  byId('inventario').scrollIntoView({ behavior: 'smooth' });
});
loadSummary();
loadInventory();

