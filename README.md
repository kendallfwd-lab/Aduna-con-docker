# ADUANA360 · Laboratorio #3 — Inventario aduanero + SQL + n8n + DeepSeek

Proyecto académico funcional: **PostgreSQL 16 + API Node.js + panel de consulta + n8n AI Agent + DeepSeek Chat Model**. Incluye datos simulados de Costa Rica para demostrar consultas de mercancías, declaraciones, inspecciones, pagos y tasas arancelarias didácticas.

> **Aviso:** Todos los importadores, cédulas, tasas, inspecciones, pagos y declaraciones son inventados. Las tasas arancelarias del ejercicio NO son tarifas oficiales; nunca utilizarlas para cobrar impuestos ni tomar decisiones reales.

## Requisito previo

- **Docker Desktop** instalado y abierto (Windows 10/11, macOS o Linux con Docker Compose).
- Clave **API de DeepSeek** válida, con acceso y saldo/crédito donde corresponda. No es la contraseña de inicio de sesión de DeepSeek.
- Navegador web; no hace falta instalar PostgreSQL, Node.js ni n8n por separado.

## Windows: inicia desde cero

1. Descomprime este ZIP y abre la carpeta `ADUANA_INTELIGENTE_LAB3`.
2. Abre PowerShell en esa carpeta (barra de dirección del Explorador: escribe `powershell`).
3. Crea tu archivo local de configuración:

   ```powershell
   Copy-Item .env.example .env
   notepad .env
   ```

4. En `.env`, cambia **solo** `PEGA_AQUI_TU_API_KEY_DE_DEEPSEEK` por tu clave real. Guarda y cierra el Bloc de notas. **No compartas ni subas `.env` a GitHub.**
5. Inicia las tres aplicaciones:

   ```powershell
   docker compose up -d --build
   ```

   La primera descarga de imágenes puede durar varios minutos. Verifica:

   ```powershell
   docker compose ps
   Invoke-RestMethod http://localhost:3000/api/health
   ```

6. Abre **http://localhost:3000** para ver el inventario. Haz clic en **Aplicar ejemplo**; deberías ver **7 registros** de mercancía de China retenida en Bodega 2 (son siete líneas de inventario, no siete contenedores).
7. Abre **http://localhost:5678**. En tu PRIMER acceso, completa el formulario de creación del usuario **propietario** de n8n. Este usuario y contraseña son para entrar a tu n8n local; los eliges tú.
8. Regresa a PowerShell e importa automáticamente la credencial DeepSeek y el workflow:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\02_configurar_n8n.ps1
   ```

9. En n8n, abre **Workflows** → **LAB3 | Agente aduanero DeepSeek | Chat**. Abre el editor y pulsa **Chat / Test workflow** en la parte inferior. Pregunta:

   **¿Qué mercancías de China siguen retenidas en la bodega 2?**

   El agente debe invocar `Buscar_mercancias` y contestar usando la base de datos real.

**Importante:** la credencial debe asignarse automáticamente al nodo DeepSeek por su ID. Si n8n muestra un triángulo rojo de credencial, abre `DeepSeek Chat Model` → **Credential** → selecciona `DeepSeek Laboratorio 3`; si no aparece, crea una credencial `DeepSeek API` e introduce la misma clave. Esta es una alternativa ante diferencias de versión/propietario de n8n.

## macOS / Linux

En Terminal, dentro de la carpeta del proyecto:

```bash
cp .env.example .env
# Edita .env y pega tu DeepSeek API key
docker compose up -d --build
# Crea primero la cuenta propietaria en http://localhost:5678
sh scripts/02_configurar_n8n.sh
```

## Enlaces y puertos

| Dirección | Qué abre |
|---|---|
| http://localhost:3000 | Panel visual de inventario |
| http://localhost:3000/api/health | Salud de la API/PostgreSQL |
| http://localhost:3000/api/mercancias | Mercancías (JSON) |
| http://localhost:3000/api/resumen | Estadísticas (JSON) |
| http://localhost:3000/api/declaraciones | Declaraciones (JSON) |
| http://localhost:3000/api/inspecciones | Inspecciones (JSON) |
| http://localhost:3000/api/pagos | Pagos (JSON) |
| http://localhost:3000/api/aranceles | Tasas didácticas (JSON) |
| http://localhost:5678 | Editor y chat de n8n |

Ejemplo de petición HTTP GET que puedes usar en navegador o Postman:

`http://localhost:3000/api/mercancias?pais=China&bodega=Bodega%202&estado=RETENIDA`

### Ejercicios SQL en PostgreSQL

```powershell
docker compose exec -T db psql -U aduana_admin -d aduana_lab3 -f /docker-entrypoint-initdb.d/consultas_ejemplo.sql
```

Para abrir SQL interactivo:

```powershell
docker compose exec db psql -U aduana_admin -d aduana_lab3
```

Dentro de `psql`: `\dt` lista tablas; `\dv` lista vistas; `\q` sale.

### Tests, logs y detener

```powershell
docker compose ps
docker compose logs --tail=100 db
docker compose logs --tail=100 api
docker compose logs --tail=100 n8n
docker compose stop
docker compose start
```

**No uses `docker compose down -v` si necesitas conservar tus datos**: elimina los volúmenes (base de datos y configuración de n8n) y obligaría a reiniciar el laboratorio. `docker compose down` sin `-v` conserva datos, pero puedes preferir `stop`.

## Archivos y entregables

```text
ADUANA_INTELIGENTE_LAB3/
├── compose.yaml                    3 servicios Docker: db, api, n8n
├── .env.example                   única clave DeepSeek configurable
├── database/
│   ├── 01_schema.sql              10 tablas + PK + FK + CHECK + índices
│   ├── 02_datos_demo.sql          datos inventados de prueba
│   ├── 03_vistas_seguridad.sql    vistas SELECT + usuario de solo lectura
│   └── consultas_ejemplo.sql      consultas con JOIN y filtros
├── api/
│   ├── src/                      consultas parametrizadas + servidor
│   ├── public/                   panel responsive sin dependencias JS extra
│   └── test/                     pruebas unitarias
├── n8n/
│   ├── AGENTE_ADUANA_DEEPSEEK_CHAT.json  flujo importable por separado
│   └── provisionar.mjs           vincula la clave al flujo
├── scripts/
│   ├── 02_configurar_n8n.ps1
│   └── 02_configurar_n8n.sh
└── docs/
    ├── GUIA_ESTUDIO_LAB3.pdf        investigación previa, 6 páginas
    ├── DIAGRAMA_ER.md
    ├── DEFENSA_PRESENTACION.md
    └── COMPROBACIONES.md
```

### Cómo funciona de verdad

1. Un funcionario escribe en el Chat Trigger de n8n.
2. `AI Agent` utiliza `DeepSeek Chat Model`.
3. Según la pregunta, llama a la herramienta HTTP correspondiente (por ejemplo, `Buscar_mercancias`).
4. La API Node.js consulta PostgreSQL mediante el usuario `aduana_consulta`, que solo puede leer las **cinco vistas autorizadas**.
5. PostgreSQL devuelve filas reales; el agente explica esos resultados.

Esta variante usa **HTTP Request Tool + API de lectura + PostgreSQL** como herramienta del agente. La conexión con PostgreSQL no es un `Postgres Tool` nativo dentro de n8n: pasa por la API local para limitar las consultas posibles y hacerlas parametrizadas. Cumple el objetivo de que el agente **consulte una base de datos relacional**, pero si tu profesor exige específicamente un nodo nativo de Postgres conectado directamente a n8n, tendríamos que sustituir la herramienta.

### Seguridad y alcance

- Entorno exclusivamente **local**, con puertos expuestos en `127.0.0.1`.
- Contraseñas PostgreSQL demo conocidas y fijas **solo** para facilitar la práctica local. Cambiarlas antes de cualquier despliegue público.
- API y n8n conectados por red interna Docker; el puerto 5432 no se expone al equipo anfitrión.
- Usuario SQL sin permisos de edición; API GET con SQL parametrizado y límites de filas.
- **La API key DeepSeek sigue siendo privada**: se guarda en tu `.env` local, n8n la importa como credencial y elimina el archivo temporal de importación. No metas la clave dentro del JSON del workflow.
- No usarlo en producción ni con mercancía real sin autenticación, auditoría, gestión segura de secretos y reglas aduaneras actualizadas.

### Recursos consultados

- [PostgreSQL — restricciones](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [PostgreSQL — GRANT](https://www.postgresql.org/docs/current/sql-grant.html)
- [n8n — AI Agent](https://docs.n8n.io/integrations/builtin/cluster-nodes/root-nodes/n8n-nodes-langchain.agent/)
- [n8n — DeepSeek Chat Model](https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.lmchatdeepseek/)
- [n8n — importar workflows/credenciales CLI](https://docs.n8n.io/deploy/host-n8n/configure-n8n/use-the-command-line/)
- [Organización Mundial de Aduanas — Sistema Armonizado](https://www.wcoomd.org/en/topics/nomenclature/overview/what-is-the-harmonized-system.aspx)

