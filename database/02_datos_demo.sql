BEGIN;

INSERT INTO paises (nombre, codigo_iso) VALUES
 ('China','CN'),('México','MX'),('Estados Unidos','US'),('Japón','JP'),
 ('Alemania','DE'),('Costa Rica','CR'),('Corea del Sur','KR'),('Brasil','BR');

INSERT INTO importadores (cedula_juridica,razon_social,correo,telefono) VALUES
 ('3-101-000101','Tecnología del Pacífico S.A.','compras@pacifico.example','2666-1001'),
 ('3-101-000102','Importadora Nicoya S.R.L.','info@nicoya.example','2666-1002'),
 ('3-101-000103','Electro Costa Rica S.A.','admin@electro.example','2666-1003'),
 ('3-101-000104','Logística del Golfo S.A.','ventas@golfo.example','2666-1004'),
 ('3-101-000105','Repuestos del Valle S.A.','hola@valle.example','2666-1005'),
 ('3-101-000106','Comercial Marina S.A.','marina@marina.example','2666-1006'),
 ('3-101-000107','Computadoras Ticas S.A.','soporte@ticas.example','2666-1007'),
 ('3-101-000108','Global Textiles S.A.','compras@textiles.example','2666-1008'),
 ('3-101-000109','Industria Puntarenas S.A.','contacto@industria.example','2666-1009'),
 ('3-101-000110','Costa Importaciones S.A.','contacto@costaimp.example','2666-1010');

INSERT INTO bodegas (nombre,ubicacion,capacidad_unidades) VALUES
 ('Bodega 1','Zona portuaria, sector A',12000),
 ('Bodega 2','Zona portuaria, sector B',14000),
 ('Bodega 3','Centro logístico, sector C',9000),
 ('Bodega 4','Zona de tránsito, sector D',8000);

-- Códigos HS/SA ilustrativos; tasas DEMOSTRATIVAS, no oficiales.
INSERT INTO partidas_arancelarias (codigo_sa,descripcion) VALUES
 ('847130','Computadoras portátiles'),
 ('851713','Teléfonos inteligentes'),
 ('850440','Convertidores estáticos y cargadores'),
 ('844332','Impresoras y dispositivos periféricos'),
 ('620342','Pantalones de algodón'),
 ('870899','Partes y accesorios de vehículos'),
 ('950300','Juguetes'),
 ('851762','Equipos de comunicación de datos');

INSERT INTO aranceles (partida_id,descripcion,tasa_porcentaje,fecha_inicio) VALUES
 (1,'Tasa simulada de importación',5,DATE '2026-01-01'),
 (2,'Tasa simulada de importación',8,DATE '2026-01-01'),
 (3,'Tasa simulada de importación',6,DATE '2026-01-01'),
 (4,'Tasa simulada de importación',4,DATE '2026-01-01'),
 (5,'Tasa simulada de importación',12,DATE '2026-01-01'),
 (6,'Tasa simulada de importación',9,DATE '2026-01-01'),
 (7,'Tasa simulada de importación',7,DATE '2026-01-01'),
 (8,'Tasa simulada de importación',5,DATE '2026-01-01');

INSERT INTO declaraciones (numero,importador_id,pais_origen_id,regimen,fecha_declaracion,estado) VALUES
 ('DUA-2026-0001',1,1,'IMPORTACION','2026-10-10','EN_REVISION'),
 ('DUA-2026-0002',2,2,'IMPORTACION','2026-10-11','AUTORIZADA'),
 ('DUA-2026-0003',3,1,'IMPORTACION','2026-10-12','EN_TRAMITE'),
 ('DUA-2026-0004',4,3,'TRANSITO','2026-10-12','EN_TRAMITE'),
 ('DUA-2026-0005',5,4,'IMPORTACION','2026-10-13','AUTORIZADA'),
 ('DUA-2026-0006',6,5,'DEPOSITO','2026-10-14','EN_REVISION'),
 ('DUA-2026-0007',7,1,'IMPORTACION','2026-10-15','EN_REVISION'),
 ('DUA-2026-0008',8,7,'IMPORTACION','2026-10-16','AUTORIZADA'),
 ('DUA-2026-0009',9,8,'IMPORTACION','2026-10-17','EN_TRAMITE'),
 ('DUA-2026-0010',10,2,'IMPORTACION','2026-10-18','CERRADA'),
 ('DUA-2026-0011',1,1,'IMPORTACION','2026-10-19','EN_REVISION'),
 ('DUA-2026-0012',4,6,'EXPORTACION','2026-10-20','AUTORIZADA');

INSERT INTO contenedores (codigo,declaracion_id,tipo,fecha_llegada)
SELECT 'CONT-2026-' || LPAD(id::text,4,'0'),id,'40 pies',fecha_declaracion FROM declaraciones ORDER BY id;

INSERT INTO mercancias (declaracion_id,contenedor_id,partida_id,bodega_id,descripcion,cantidad,valor_usd,estado,fecha_ingreso) VALUES
 (1,1,1,2,'Laptops de oficina',50,22500,'RETENIDA','2026-10-10'),
 (1,1,2,2,'Teléfonos inteligentes',100,19000,'RETENIDA','2026-10-10'),
 (1,1,3,1,'Cargadores USB-C',250,3750,'EN_DEPOSITO','2026-10-10'),
 (2,2,4,2,'Impresoras térmicas',20,4200,'LIBERADA','2026-10-11'),
 (2,2,5,1,'Pantalones de algodón',400,8000,'LIBERADA','2026-10-11'),
 (3,3,3,2,'Cargadores para teléfono',800,9600,'RETENIDA','2026-10-12'),
 (3,3,7,3,'Juguetes electrónicos',150,6000,'EN_INSPECCION','2026-10-12'),
 (3,3,8,2,'Routers Wi-Fi',120,8400,'RETENIDA','2026-10-12'),
 (4,4,6,4,'Repuestos industriales',80,13000,'EN_DEPOSITO','2026-10-12'),
 (4,4,8,4,'Equipos de comunicación',30,9000,'EN_DEPOSITO','2026-10-12'),
 (5,5,6,3,'Filtros de automóvil',200,12000,'LIBERADA','2026-10-13'),
 (5,5,8,1,'Equipos de red',75,15500,'LIBERADA','2026-10-13'),
 (6,6,5,3,'Textiles europeos',500,18500,'EN_DEPOSITO','2026-10-14'),
 (6,6,4,3,'Impresoras de etiquetas',45,5100,'EN_INSPECCION','2026-10-14'),
 (7,7,1,2,'Computadoras para estudiantes',60,24600,'RETENIDA','2026-10-15'),
 (7,7,2,2,'Smartphones gama media',90,13500,'RETENIDA','2026-10-15'),
 (7,7,3,3,'Adaptadores de corriente',300,2400,'EN_DEPOSITO','2026-10-15'),
 (8,8,2,1,'Teléfonos coreanos',120,36600,'LIBERADA','2026-10-16'),
 (8,8,8,1,'Switches de red',55,14850,'LIBERADA','2026-10-16'),
 (9,9,5,3,'Uniformes industriales',260,10400,'EN_INSPECCION','2026-10-17'),
 (9,9,7,3,'Juguetes didácticos',95,2850,'EN_DEPOSITO','2026-10-17'),
 (10,10,4,1,'Impresoras láser',15,4500,'LIBERADA','2026-10-18'),
 (10,10,6,1,'Partes mecánicas',70,8400,'LIBERADA','2026-10-18'),
 (11,11,3,2,'Baterías externas y cargadores',140,7000,'RETENIDA','2026-10-19'),
 (11,11,8,2,'Dispositivos de conectividad',80,9200,'EN_INSPECCION','2026-10-19'),
 (11,11,1,1,'Laptops para diseño',25,32500,'EN_DEPOSITO','2026-10-19'),
 (12,12,7,4,'Juguetes fabricados localmente',60,1200,'EN_DEPOSITO','2026-10-20'),
 (12,12,5,4,'Prendas nacionales',170,5100,'EN_DEPOSITO','2026-10-20'),
 (2,2,6,2,'Partes de motor',30,6300,'LIBERADA','2026-10-11'),
 (5,5,3,3,'Convertidores de voltaje',85,4250,'LIBERADA','2026-10-13');

INSERT INTO inspecciones (mercancia_id,funcionario,fecha_inspeccion,resultado,observaciones) VALUES
 (1,'Ana Méndez','2026-10-11','OBSERVACIONES','Número de serie pendiente de verificación'),
 (2,'Carlos Mora','2026-10-11','PENDIENTE','Revisar documentación de homologación'),
 (4,'Lucía Quesada','2026-10-12','APROBADA','Coincide con la declaración'),
 (6,'Ana Méndez','2026-10-13','RECHAZADA','Etiquetado incompleto'),
 (7,'Mario Rojas','2026-10-14','PENDIENTE','Inspección física programada'),
 (8,'Ana Méndez','2026-10-14','OBSERVACIONES','Solicitar fichas técnicas'),
 (11,'Carlos Mora','2026-10-14','APROBADA','Sin observaciones'),
 (14,'Lucía Quesada','2026-10-15','PENDIENTE','Verificación de modelos'),
 (15,'Mario Rojas','2026-10-16','OBSERVACIONES','Falta documentación complementaria'),
 (16,'Mario Rojas','2026-10-16','PENDIENTE','Validación de IMEI'),
 (18,'Ana Méndez','2026-10-17','APROBADA','Inspección satisfactoria'),
 (20,'Carlos Mora','2026-10-18','PENDIENTE','Muestras pendientes'),
 (24,'Ana Méndez','2026-10-20','RECHAZADA','Etiquetado por corregir'),
 (25,'Lucía Quesada','2026-10-20','PENDIENTE','Revisar expediente técnico'),
 (26,'Mario Rojas','2026-10-21','APROBADA','Sin incidencias');

INSERT INTO pagos (declaracion_id,referencia,monto_usd,fecha_pago,estado) VALUES
 (1,'PAG-0001',1550,'2026-10-11','PENDIENTE'),
 (2,'PAG-0002',965,'2026-10-12','PAGADO'),
 (3,'PAG-0003',820,'2026-10-13','PENDIENTE'),
 (4,'PAG-0004',400,'2026-10-13','PENDIENTE'),
 (5,'PAG-0005',1980,'2026-10-14','PAGADO'),
 (6,'PAG-0006',1200,'2026-10-15','PENDIENTE'),
 (7,'PAG-0007',2700,'2026-10-16','PENDIENTE'),
 (8,'PAG-0008',3100,'2026-10-17','PAGADO'),
 (9,'PAG-0009',750,'2026-10-18','PENDIENTE'),
 (10,'PAG-0010',690,'2026-10-19','PAGADO'),
 (11,'PAG-0011',4100,'2026-10-20','PENDIENTE'),
 (12,'PAG-0012',250,'2026-10-21','PAGADO');

COMMIT;

