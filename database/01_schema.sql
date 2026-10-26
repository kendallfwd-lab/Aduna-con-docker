BEGIN;

CREATE TABLE paises (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  codigo_iso CHAR(2) NOT NULL UNIQUE
);

CREATE TABLE importadores (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  cedula_juridica VARCHAR(30) NOT NULL UNIQUE,
  razon_social VARCHAR(160) NOT NULL,
  correo VARCHAR(180),
  telefono VARCHAR(40)
);

CREATE TABLE bodegas (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  ubicacion VARCHAR(180) NOT NULL,
  capacidad_unidades INTEGER NOT NULL CHECK (capacidad_unidades > 0)
);

CREATE TABLE partidas_arancelarias (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo_sa CHAR(6) NOT NULL UNIQUE CHECK (codigo_sa ~ '^[0-9]{6}$'),
  descripcion VARCHAR(200) NOT NULL
);

CREATE TABLE aranceles (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  partida_id INTEGER NOT NULL REFERENCES partidas_arancelarias(id),
  descripcion VARCHAR(120) NOT NULL,
  tasa_porcentaje NUMERIC(6,2) NOT NULL CHECK (tasa_porcentaje BETWEEN 0 AND 100),
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

CREATE TABLE declaraciones (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  numero VARCHAR(35) NOT NULL UNIQUE,
  importador_id INTEGER NOT NULL REFERENCES importadores(id),
  pais_origen_id INTEGER NOT NULL REFERENCES paises(id),
  regimen VARCHAR(20) NOT NULL CHECK (regimen IN ('IMPORTACION','EXPORTACION','TRANSITO','DEPOSITO')),
  fecha_declaracion DATE NOT NULL,
  estado VARCHAR(20) NOT NULL DEFAULT 'EN_TRAMITE'
    CHECK (estado IN ('EN_TRAMITE','EN_REVISION','AUTORIZADA','CERRADA'))
);

CREATE TABLE contenedores (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  codigo VARCHAR(30) NOT NULL UNIQUE,
  declaracion_id INTEGER NOT NULL REFERENCES declaraciones(id),
  tipo VARCHAR(35) NOT NULL,
  fecha_llegada DATE NOT NULL
);

CREATE TABLE mercancias (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  declaracion_id INTEGER NOT NULL REFERENCES declaraciones(id),
  contenedor_id INTEGER REFERENCES contenedores(id),
  partida_id INTEGER NOT NULL REFERENCES partidas_arancelarias(id),
  bodega_id INTEGER REFERENCES bodegas(id),
  descripcion VARCHAR(200) NOT NULL,
  cantidad INTEGER NOT NULL CHECK (cantidad > 0),
  valor_usd NUMERIC(14,2) NOT NULL CHECK (valor_usd >= 0),
  estado VARCHAR(20) NOT NULL DEFAULT 'EN_DEPOSITO'
    CHECK (estado IN ('RETENIDA','EN_INSPECCION','EN_DEPOSITO','LIBERADA')),
  fecha_ingreso DATE NOT NULL
);

CREATE TABLE inspecciones (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mercancia_id INTEGER NOT NULL REFERENCES mercancias(id),
  funcionario VARCHAR(120) NOT NULL,
  fecha_inspeccion DATE NOT NULL,
  resultado VARCHAR(30) NOT NULL
    CHECK (resultado IN ('APROBADA','OBSERVACIONES','RECHAZADA','PENDIENTE')),
  observaciones TEXT
);

CREATE TABLE pagos (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  declaracion_id INTEGER NOT NULL REFERENCES declaraciones(id),
  referencia VARCHAR(50) NOT NULL UNIQUE,
  monto_usd NUMERIC(14,2) NOT NULL CHECK (monto_usd > 0),
  fecha_pago DATE NOT NULL,
  estado VARCHAR(12) NOT NULL CHECK (estado IN ('PENDIENTE','PAGADO','ANULADO'))
);

-- Un contenedor solo puede referirse a mercancías de su propia declaración.
ALTER TABLE contenedores ADD CONSTRAINT contenedores_id_declaracion_unique
  UNIQUE (id, declaracion_id);
ALTER TABLE mercancias ADD CONSTRAINT mercancias_contenedor_misma_declaracion
  FOREIGN KEY (contenedor_id, declaracion_id)
  REFERENCES contenedores(id, declaracion_id);

CREATE INDEX idx_mercancias_estado_bodega ON mercancias(estado, bodega_id);
CREATE INDEX idx_mercancias_declaracion ON mercancias(declaracion_id);
CREATE INDEX idx_declaraciones_pais ON declaraciones(pais_origen_id);
CREATE INDEX idx_inspecciones_mercancia ON inspecciones(mercancia_id);
CREATE INDEX idx_pagos_declaracion ON pagos(declaracion_id);

COMMIT;

