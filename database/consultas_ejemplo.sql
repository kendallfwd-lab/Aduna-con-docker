-- Ejemplo principal del profesor:
SELECT mercancia, cantidad, pais_origen, bodega, estado
FROM v_inventario_consulta
WHERE pais_origen = 'China'
  AND bodega = 'Bodega 2'
  AND estado = 'RETENIDA'
ORDER BY mercancia_id;

-- Otras preguntas de ejemplo:
SELECT pais_origen, COUNT(*) AS lineas_mercancia, SUM(cantidad) AS unidades
FROM v_inventario_consulta GROUP BY pais_origen ORDER BY unidades DESC;

SELECT resultado, COUNT(*) AS cantidad_inspecciones
FROM v_inspecciones_consulta GROUP BY resultado ORDER BY cantidad_inspecciones DESC;

SELECT declaracion, monto_usd, estado FROM v_pagos_consulta
WHERE estado = 'PENDIENTE' ORDER BY monto_usd DESC;

