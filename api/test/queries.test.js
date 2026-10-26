import test from 'node:test';
import assert from 'node:assert/strict';
import { buildQuery, parseLimit, resumenSQL } from '../src/queries.js';

test('la búsqueda parametriza los filtros, no concatena SQL inseguro', () => {
  const p = new URLSearchParams({ pais: "China'; DROP TABLE mercancias; --", bodega: '2', estado: 'retenida' });
  const result = buildQuery('/api/mercancias', p);
  assert.ok(result.text.includes('LIMIT $5'));
  assert.ok(!result.text.includes('DROP TABLE'));
  assert.equal(result.values[0], "China'; DROP TABLE mercancias; --");
  assert.equal(result.values[2], 'RETENIDA');
});

test('limit queda entre 1 y 100', () => {
  assert.equal(parseLimit('2000'), 100);
  assert.equal(parseLimit('-5'), 50);
  assert.equal(parseLimit('0'), 50);
  assert.equal(parseLimit('abc'), 50);
  assert.equal(parseLimit('3'), 3);
});

test('solo están permitidas rutas predefinidas de lectura', () => {
  assert.equal(buildQuery('/api/eliminar', new URLSearchParams()), null);
  assert.ok(buildQuery('/api/pagos', new URLSearchParams()).text.includes('v_pagos_consulta'));
  assert.ok(resumenSQL.includes('v_inventario_consulta'));
});

