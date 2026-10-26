const max = (raw, fallback, top) => {
  const value = Number(raw);
  return Number.isSafeInteger(value) && value > 0 ? Math.min(value, top) : fallback;
};

export function parseLimit(raw) {
  return max(raw, 50, 100);
}

export function buildQuery(pathname, searchParams) {
  const limit = parseLimit(searchParams.get('limit'));
  if (pathname === '/api/mercancias') {
    const pais = (searchParams.get('pais') ?? '').trim().slice(0, 70);
    const bodega = (searchParams.get('bodega') ?? '').trim().slice(0, 70);
    const estado = (searchParams.get('estado') ?? '').trim().slice(0, 30).toUpperCase();
    const texto = (searchParams.get('texto') ?? '').trim().slice(0, 100);
    return {
      text: `SELECT * FROM v_inventario_consulta
        WHERE ($1 = '' OR pais_origen ILIKE '%' || $1 || '%')
          AND ($2 = '' OR bodega ILIKE '%' || $2 || '%')
          AND ($3 = '' OR estado = $3)
          AND ($4 = '' OR mercancia ILIKE '%' || $4 || '%')
        ORDER BY mercancia_id LIMIT $5`,
      values: [pais, bodega, estado, texto, limit]
    };
  }
  const views = {
    '/api/declaraciones': 'v_declaraciones_consulta',
    '/api/inspecciones': 'v_inspecciones_consulta',
    '/api/pagos': 'v_pagos_consulta',
    '/api/aranceles': 'v_aranceles_consulta'
  };
  const view = views[pathname];
  if (view) {
    return { text: `SELECT * FROM ${view} LIMIT $1`, values: [limit] };
  }
  return null;
}

export const resumenSQL = `
  SELECT COUNT(*)::integer AS total_lineas,
    COALESCE(SUM(cantidad),0)::bigint AS total_unidades,
    COALESCE(SUM(valor_usd),0)::numeric(14,2) AS valor_total_usd,
    COUNT(*) FILTER (WHERE estado = 'RETENIDA')::integer AS retenidas,
    COUNT(*) FILTER (WHERE estado = 'LIBERADA')::integer AS liberadas,
    COUNT(*) FILTER (WHERE estado = 'EN_INSPECCION')::integer AS en_inspeccion,
    COUNT(*) FILTER (WHERE estado = 'EN_DEPOSITO')::integer AS en_deposito
  FROM v_inventario_consulta`;

