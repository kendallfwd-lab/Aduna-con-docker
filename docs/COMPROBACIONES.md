# Comprobaciones que debes realizar en tu PC

## Prueba 1 · Servicio SQL y API

```powershell
docker compose ps
Invoke-RestMethod http://localhost:3000/api/health
```

Esperado: `ok: true` y `baseDeDatos: conectada`.

## Prueba 2 · Consulta del enunciado

```powershell
Invoke-RestMethod 'http://localhost:3000/api/mercancias?pais=China&bodega=Bodega%202&estado=RETENIDA'
```

Esperado: `total: 7` registros. Entre ellos hay laptops, teléfonos inteligentes y cargadores.

## Prueba 3 · Usuario sin permiso de edición

Este comando **no modifica ninguna tabla**: muestra los privilegios del rol de lectura.

```powershell
docker compose exec -T db psql -U aduana_admin -d aduana_lab3 -c "SELECT has_table_privilege('aduana_consulta','mercancias','UPDATE') AS puede_actualizar, has_table_privilege('aduana_consulta','v_inventario_consulta','SELECT') AS puede_leer_vista;"
```

Esperado: `puede_actualizar = f`, `puede_leer_vista = t`.

## Prueba 4 · Restricción de cantidad positiva

Inspecciona la definición (sin modificar nada):

```powershell
docker compose exec -T db psql -U aduana_admin -d aduana_lab3 -c "\d mercancias"
```

Busca `CHECK (cantidad > 0)` y la FK compuesta de contenedor + declaración.

## Prueba 5 · Workflow

1. Abre `http://localhost:5678`.
2. Encuentra `LAB3 | Agente aduanero DeepSeek | Chat`.
3. Pulsa **Test workflow / Chat**.
4. Haz las preguntas del documento de defensa.
5. Confirma que aparece un resultado en `Buscar_mercancias` o `Resumen_inventario`, y después la respuesta del agente.

**Diagnóstico rápido:**

- `ECONNREFUSED` hacia PostgreSQL: comprueba que el servicio `db` indique `healthy`.
- HTTP tool de n8n no alcanza la API: verifica `docker compose logs api` y que la URL del nodo use `http://api:3000`, **no** `localhost:3000` (dentro de n8n, `localhost` es el mismo contenedor).
- DeepSeek falla con `401`: clave API incorrecta o no vinculada al modelo en n8n.
- DeepSeek falla con saldo insuficiente: revisa la consola/cuenta del proveedor.
- El workflow no se ve: importa manualmente `n8n/AGENTE_ADUANA_DEEPSEEK_CHAT.json` desde el menú de n8n. Si aparece sin credencial, selecciona/crea `DeepSeek Laboratorio 3`.
- Modificaste `.env` luego de levantar: ejecuta `docker compose up -d --force-recreate n8n`, y después el script de configuración para actualizar la credencial.
- Las tablas no se vuelven a crear al reiniciar: es correcto, PostgreSQL conserva datos en su volumen. Los `*.sql` inicializan únicamente el primer arranque con volumen nuevo.

## Cobertura de pruebas locales automatizadas (sin Docker)

En `api/` corre `npm test` con Node.js 20+. Estas pruebas validan los constructores SQL y sus límites, **pero no prueban** una conexión real a PostgreSQL ni una respuesta real de DeepSeek.

