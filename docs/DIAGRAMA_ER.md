# Diagrama Entidad-Relación (DER) del inventario aduanero

Este es el modelo relacional. Las PK identifican filas y las FK permiten relacionar tablas sin duplicar nombres de países, bodegas o importadores en cada mercancía.

```mermaid
erDiagram
    PAISES ||--o{ DECLARACIONES : origen
    IMPORTADORES ||--o{ DECLARACIONES : presenta
    DECLARACIONES ||--o{ CONTENEDORES : transporta
    DECLARACIONES ||--o{ MERCANCIAS : incluye
    CONTENEDORES o|--o{ MERCANCIAS : contiene
    BODEGAS o|--o{ MERCANCIAS : almacena
    PARTIDAS_ARANCELARIAS ||--o{ MERCANCIAS : clasifica
    PARTIDAS_ARANCELARIAS ||--o{ ARANCELES : tasa
    MERCANCIAS ||--o{ INSPECCIONES : revisa
    DECLARACIONES ||--o{ PAGOS : paga

    PAISES { int id PK
             varchar nombre
             char codigo_iso }
    IMPORTADORES { int id PK
                  varchar cedula_juridica UK
                  varchar razon_social }
    BODEGAS { int id PK
              varchar nombre
              integer capacidad_unidades }
    PARTIDAS_ARANCELARIAS { int id PK
                            char codigo_sa UK
                            varchar descripcion }
    ARANCELES { int id PK
                int partida_id FK
                decimal tasa_porcentaje }
    DECLARACIONES { int id PK
                    varchar numero UK
                    int importador_id FK
                    int pais_origen_id FK
                    varchar regimen }
    CONTENEDORES { int id PK
                   varchar codigo UK
                   int declaracion_id FK }
    MERCANCIAS { int id PK
                 int declaracion_id FK
                 int contenedor_id FK
                 int partida_id FK
                 int bodega_id FK
                 varchar estado
                 integer cantidad }
    INSPECCIONES { int id PK
                   int mercancia_id FK
                   varchar resultado }
    PAGOS { int id PK
            int declaracion_id FK
            decimal monto_usd }
```

## Relaciones importantes

- **1:N** país → declaraciones: China puede figurar en muchas declaraciones.
- **1:N** importador → declaraciones: una empresa presenta múltiples declaraciones.
- **1:N** declaración → mercancías: una declaración puede tener varias líneas de productos.
- **1:N** bodega → mercancías: una bodega guarda múltiples líneas de inventario.
- **1:N** mercancía → inspecciones: una mercancía puede inspeccionarse varias veces.
- **1:N** declaración → pagos: una declaración puede tener pagos asociados.
- **N:M conceptual**: declaraciones y tipos de partidas, resuelta mediante `mercancias` que vincula ambas y guarda cantidad/valor de cada línea.
- **Restricción adicional**: el contenedor de una línea de mercancía debe pertenecer a la misma declaración, protegida con FK compuesta `(contenedor_id, declaracion_id)`.

## Normalización

- **1FN:** cada valor es atómico, por ejemplo un solo `codigo_iso` por país.
- **2FN:** atributos como razón social dependen de la PK de su tabla (`importadores`), no de un identificador parcial.
- **3FN:** en `mercancias` almacenamos `bodega_id` en vez de repetir el nombre o dirección de cada bodega; país/razón social también viven en sus propias tablas.

**Cómo ver el DER:** abre este `.md` en GitHub o en un editor con soporte Mermaid. Puedes pegar el bloque en https://mermaid.live para descargar un SVG o PNG para tu presentación.

