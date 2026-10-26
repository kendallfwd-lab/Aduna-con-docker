BEGIN;

CREATE VIEW v_inventario_consulta WITH (security_barrier = true) AS
SELECT m.id AS mercancia_id, m.descripcion AS mercancia, m.cantidad,
       m.valor_usd, m.estado, m.fecha_ingreso,
       b.nombre AS bodega, b.id AS bodega_id,
       p.nombre AS pais_origen, p.codigo_iso,
       i.razon_social AS importador,
       d.numero AS declaracion, d.regimen,
       c.codigo AS contenedor, pa.codigo_sa AS partida_sa
FROM mercancias m
JOIN declaraciones d ON d.id = m.declaracion_id
JOIN paises p ON p.id = d.pais_origen_id
JOIN importadores i ON i.id = d.importador_id
LEFT JOIN bodegas b ON b.id = m.bodega_id
LEFT JOIN contenedores c ON c.id = m.contenedor_id
JOIN partidas_arancelarias pa ON pa.id = m.partida_id;

CREATE VIEW v_inspecciones_consulta WITH (security_barrier = true) AS
SELECT ins.id AS inspeccion_id, ins.fecha_inspeccion,
       ins.funcionario, ins.resultado, ins.observaciones,
       v.mercancia, v.pais_origen, v.bodega, v.declaracion
FROM inspecciones ins
JOIN v_inventario_consulta v ON v.mercancia_id = ins.mercancia_id;

CREATE VIEW v_declaraciones_consulta WITH (security_barrier = true) AS
SELECT d.numero, d.fecha_declaracion, d.estado, d.regimen,
       p.nombre AS pais_origen, i.razon_social AS importador,
       COUNT(m.id)::integer AS total_lineas,
       COALESCE(SUM(m.cantidad),0)::bigint AS total_unidades,
       COALESCE(SUM(m.valor_usd),0)::numeric(14,2) AS valor_total_usd
FROM declaraciones d
JOIN paises p ON p.id = d.pais_origen_id
JOIN importadores i ON i.id = d.importador_id
LEFT JOIN mercancias m ON m.declaracion_id = d.id
GROUP BY d.id, p.nombre, i.razon_social;

CREATE VIEW v_pagos_consulta WITH (security_barrier = true) AS
SELECT p.referencia, p.monto_usd, p.fecha_pago, p.estado,
       d.numero AS declaracion, i.razon_social AS importador
FROM pagos p
JOIN declaraciones d ON d.id = p.declaracion_id
JOIN importadores i ON i.id = d.importador_id;

CREATE VIEW v_aranceles_consulta WITH (security_barrier = true) AS
SELECT a.descripcion AS concepto, a.tasa_porcentaje,
       a.fecha_inicio, a.fecha_fin, pa.codigo_sa, pa.descripcion AS partida
FROM aranceles a JOIN partidas_arancelarias pa ON pa.id = a.partida_id;

-- La IA SOLO verá las 5 vistas, NUNCA las tablas físicas.
CREATE ROLE aduana_consulta LOGIN PASSWORD 'aduana_lector_demo_2026';
GRANT CONNECT ON DATABASE aduana_lab3 TO aduana_consulta;
GRANT USAGE ON SCHEMA public TO aduana_consulta;
GRANT SELECT ON v_inventario_consulta, v_inspecciones_consulta,
  v_declaraciones_consulta, v_pagos_consulta, v_aranceles_consulta TO aduana_consulta;
ALTER ROLE aduana_consulta SET default_transaction_read_only = on;
ALTER ROLE aduana_consulta SET statement_timeout = '4000ms';

COMMIT;

