# Guion breve para defender el Laboratorio #3

## 1. Problema (30 segundos)

"La aduana recibe mercancías de varios países. Si la información está repartida entre hojas de cálculo, es difícil saber en qué bodega está un lote, si fue inspeccionado o si sigue retenido. Diseñamos un modelo relacional que centraliza estos datos."

## 2. Diseño (1 minuto)

"Tenemos diez tablas relacionadas. Cada mercancía guarda referencias a su declaración, partida arancelaria, contenedor y bodega. Con llaves primarias y foráneas evitamos registros huérfanos; con CHECK evitamos cantidades negativas o estados inventados. La declaración conecta al importador y al país de origen."

## 3. SQL (1 minuto)

"Creamos todo con CREATE TABLE, INSERT INTO y constraints. En los datos de prueba registramos 30 líneas de mercancías, 12 declaraciones y 4 bodegas. Con JOIN podemos preguntar por origen, bodega y estado. Una consulta real del ejemplo filtra pais_origen=China, bodega=Bodega 2, estado=RETENIDA."

## 4. Seguridad (40 segundos)

"El chatbot no recibe permiso para modificar el inventario. Solo consulta cinco vistas de lectura, a través de una API que usa parámetros y limita la cantidad de filas. El acceso público se encuentra únicamente en localhost. Los importadores y tasas arancelarias son ficticios."

## 5. IA / n8n (1 minuto)

"En n8n, el Chat Trigger recibe la pregunta. El AI Agent usa DeepSeek Chat Model y selecciona la herramienta que necesita. Buscar_mercancias consulta la API, que consulta PostgreSQL, y devuelve filas. La IA convierte esos resultados en una respuesta en español. El modelo no es la base de datos: no debe inventar mercancías que no existen."

## 6. Demo (2 minutos)

1. Abre `http://localhost:3000`. Enseña totales y filtros.
2. Pulsa **Aplicar ejemplo** (China + Bodega 2 + RETENIDA). Explica la cantidad de líneas.
3. Abre n8n, ejecuta el chat del workflow y pregunta: "¿Qué mercancías de China siguen retenidas en la bodega 2?".
4. Inspecciona en n8n la ejecución de la herramienta `Buscar_mercancias`.
5. Pregunta: "¿Cuántas líneas retenidas hay en total?" y observa la herramienta de resumen.
6. Señala que el usuario no puede eliminar mercancías mediante ese chat.

## 7. IA como asistente (30 segundos)

"Usamos IA para investigar SQL, proponer el esquema y generar un borrador inicial del código. Luego revisamos llaves, tipos, vistas, pruebas y seguridad. La IA ayuda, pero la verdad del inventario la proporciona PostgreSQL."

## Preguntas que podría hacer el profesor

- **¿Qué es PK?** Es un identificador único de cada fila.
- **¿Qué es FK?** Es una referencia que exige que el registro relacionado exista.
- **¿Qué hace un JOIN?** Combina información de tablas relacionadas, como mercancía + país.
- **¿Qué es 3FN?** Una organización que evita guardar datos repetidos que dependen de otra entidad.
- **¿Qué diferencia hay entre LLM y agente?** El LLM genera texto; el agente puede seleccionar herramientas para obtener información externa.
- **¿Por qué una API entre n8n y SQL?** Para limitar consultas a filtros predefinidos, proteger la base y evitar SQL generado sin control.
- **¿Cómo garantizan que no edite?** La API solo ofrece GET y el rol PostgreSQL `aduana_consulta` solo tiene `SELECT` sobre vistas.

