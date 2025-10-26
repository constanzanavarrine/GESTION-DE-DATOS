-- ============================================
-- CREACIÓN DE TABLAS
-- ============================================

CREATE TABLE ALUMNO_cn
(
  LEGAJO CHAR(5) NOT NULL,
  NOM_Y_APE VARCHAR(100) NOT NULL,
  DOMICILIO VARCHAR(100) NOT NULL,
  TELEFONO VARCHAR(50) NOT NULL,
  CP INTEGER NOT NULL,
  EMAIL VARCHAR(100) NULL
);
GO

CREATE TABLE BANCO_cn
(
  NRO_BANCO CHAR(5) NOT NULL,
  NOMBRE VARCHAR(100) NULL
);
GO

CREATE TABLE CUOTA_cn
(
  COD_CUOTA CHAR(5) NOT NULL,
  LEGAJO CHAR(5) NOT NULL,
  MES_ANIO CHAR(6) NOT NULL,
  VALOR DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE EMPLEADOS_cn
(
  NRO_EMP CHAR(5) NOT NULL,
  NOM_Y_APE VARCHAR(100) NOT NULL,
  DOMICILIO VARCHAR(100) NOT NULL,
  TELEFONO VARCHAR(50) NOT NULL,
  CP INTEGER NOT NULL
);
GO

CREATE TABLE ERRORES_POR_PAGO_cn
(
  COD_ERROR CHAR(5) NOT NULL,
  NRO_OPE CHAR(5) NOT NULL,
  FEC_HORA DATETIME NOT NULL
);
GO

CREATE TABLE ESTADO_ERROR_cn
(
  COD_ERROR CHAR(5) NOT NULL,
  DESCR VARCHAR(100) NOT NULL
);
GO

CREATE TABLE PAGOS_CUOTAS_cn
(
  NRO_OPE CHAR(5) NOT NULL,
  COD_CUOTA CHAR(5) NOT NULL,
  MONTO_PAGADO DECIMAL(10,2) NOT NULL,
  FEC_HORA DATETIME NOT NULL,
  ESTADO CHAR(5) NOT NULL,
  NRO_BANCO CHAR(5) NULL,
  NRO_EMP CHAR(5) NULL
);
GO

-- ============================================
-- CLAVES PRIMARIAS
-- ============================================

ALTER TABLE ALUMNO_cn ADD CONSTRAINT ALUMNO_PK_cn PRIMARY KEY (LEGAJO);
ALTER TABLE BANCO_cn ADD CONSTRAINT BANCO_PK_cn PRIMARY KEY (NRO_BANCO);
ALTER TABLE CUOTA_cn ADD CONSTRAINT CUOTA_PK_cn PRIMARY KEY (COD_CUOTA);
ALTER TABLE EMPLEADOS_cn ADD CONSTRAINT EMPLEADOS_PK_cn PRIMARY KEY (NRO_EMP);
ALTER TABLE ERRORES_POR_PAGO_cn ADD CONSTRAINT ERRORES_POR_PAGO_PK_cn PRIMARY KEY (COD_ERROR, NRO_OPE);
ALTER TABLE ESTADO_ERROR_cn ADD CONSTRAINT ESTADO_ERROR_PK_cn PRIMARY KEY (COD_ERROR);
ALTER TABLE PAGOS_CUOTAS_cn ADD CONSTRAINT PAGOS_CUOTAS_PK_cn PRIMARY KEY (NRO_OPE);
GO

-- ============================================
-- CLAVES FORÁNEAS
-- ============================================

ALTER TABLE CUOTA_cn ADD CONSTRAINT CUOTA_ALUMNO_FK_cn
  FOREIGN KEY (LEGAJO)
  REFERENCES ALUMNO_cn (LEGAJO);
GO

ALTER TABLE ERRORES_POR_PAGO_cn ADD CONSTRAINT ERRORES_POR_PAGO_ESTADO_ERROR_FK_cn
  FOREIGN KEY (COD_ERROR)
  REFERENCES ESTADO_ERROR_cn (COD_ERROR);
GO

ALTER TABLE ERRORES_POR_PAGO_cn ADD CONSTRAINT ERRORES_POR_PAGO_PAGOS_CUOTAS_FK_cn
  FOREIGN KEY (NRO_OPE)
  REFERENCES PAGOS_CUOTAS_cn (NRO_OPE);
GO

ALTER TABLE PAGOS_CUOTAS_cn ADD CONSTRAINT PAGOS_CUOTAS_BANCO_FK_cn
  FOREIGN KEY (NRO_BANCO)
  REFERENCES BANCO_cn (NRO_BANCO);
GO

ALTER TABLE PAGOS_CUOTAS_cn ADD CONSTRAINT PAGOS_CUOTAS_CUOTA_FK_cn
  FOREIGN KEY (COD_CUOTA)
  REFERENCES CUOTA_cn (COD_CUOTA);
GO

ALTER TABLE PAGOS_CUOTAS_cn ADD CONSTRAINT PAGOS_CUOTAS_EMPLEADOS_FK_cn
  FOREIGN KEY (NRO_EMP)
  REFERENCES EMPLEADOS_cn (NRO_EMP);
GO


-- =========================================================
-- 1) ALUMNO_cn (incluye legajo '01972')
-- =========================================================
INSERT INTO ALUMNO_cn (LEGAJO, NOM_Y_APE, DOMICILIO, TELEFONO, CP, EMAIL)
VALUES
('01972','Mario Gómez','Av. Rivadavia 1010','1111111111',1000,'mario.gomez@mail.com'),
('02001','Lucía Torres','Calle Mitre 200','1111111112',2000,'lucia.torres@mail.com'),
('02002','Juan Pérez','Av. San Martín 500','1111111113',5000,'juan.perez@mail.com'),
('02003','Ana Ruiz','Av. Corrientes 400','1111111114',4000,'ana.ruiz@mail.com'),
('02004','Diego Fernández','Av. Callao 300','1111111115',3000,'diego.fernandez@mail.com'),
('02005','Sofía López','Calle Belgrano 800','1111111116',8000,'sofia.lopez@mail.com'),
('02006','Tomás Romero','Av. Santa Fe 2500','1111111117',2500,'tomas.romero@mail.com'),
('02007','Gonzalo Díaz','Calle Lavalle 700','1111111118',7000,'gonzalo.diaz@mail.com'),
('02008','Camila Rodríguez','Av. Córdoba 2300','1111111119',2300,'camila.rod@mail.com'),
('02009','Valentina Pérez','Av. Libertador 1200','1111111120',1200,'valentina.perez@mail.com');
GO

-- =========================================================
-- 2) BANCO_cn (con espacios para practicar TRIM/UPPER)
-- =========================================================
INSERT INTO BANCO_cn (NRO_BANCO, NOMBRE)
VALUES
('B0001','  Banco Nación  '),
('B0002','Banco Galicia'),
('B0003','  Banco Santander'),
('B0004','Banco Ciudad   '),
('B0005','Banco Macro'),
('B0006','  Banco BBVA  '),
('B0007','Banco Patagonia'),
('B0008','  Banco HSBC'),
('B0009','Banco ICBC   '),
('B0010','Banco Itaú');
GO

-- =========================================================
-- 3) EMPLEADOS_cn
-- =========================================================
INSERT INTO EMPLEADOS_cn (NRO_EMP, NOM_Y_APE, DOMICILIO, TELEFONO, CP)
VALUES
('E0001','Laura Fernández','Av. Callao 300','1122334455',1000),
('E0002','Pablo Ruiz','Calle Florida 900','1133445566',2000),
('E0003','Sofía López','Av. Corrientes 400','1144556677',4000),
('E0004','Julián Torres','Rivadavia 1500','1155667788',1500),
('E0005','Marina García','Belgrano 230','1166778899',2300),
('E0006','Ignacio López','Córdoba 300','1177889900',3000),
('E0007','Gabriela Díaz','Lima 800','1188990011',8000),
('E0008','Esteban Romero','Congreso 400','1199001122',4000),
('E0009','Nicolás Herrera','Monroe 1300','1211223344',1300),
('E0010','Valeria Suárez','Cabildo 900','1200112233',9000);
GO

-- =========================================================
-- 4) ESTADO_ERROR_cn
-- =========================================================
INSERT INTO ESTADO_ERROR_cn (COD_ERROR, DESCR)
VALUES
('E001','Error en validación de datos'),
('E002','Pago duplicado'),
('E003','Error de conexión con el banco'),
('E004','Monto incorrecto'),
('E005','Pago fuera de horario'),
('E006','Falta autorización'),
('E007','Error en sistema interno'),
('E008','Cliente inexistente'),
('E009','Referencia de cuota inválida'),
('E010','Operación cancelada por el usuario');
GO

-- =========================================================
-- 5) CUOTA_cn (MMYYYY en MES_ANIO, año 2012)
-- =========================================================
INSERT INTO CUOTA_cn (COD_CUOTA, LEGAJO, MES_ANIO, VALOR)
VALUES
('C1001','01972','012012',1500.00),
('C1002','01972','022012',1600.00),
('C1003','02001','032012',1700.00),
('C1004','02002','042012',1800.00),
('C1005','02003','052012',1900.00),
('C1006','02004','062012',2000.00),
('C1007','02005','072012',2100.00),
('C1008','02006','082012',2200.00),
('C1009','02007','092012',2300.00),
('C1010','02008','102012',2400.00);
GO

-- =========================================================
-- 6) PAGOS_CUOTAS_cn (fechas 2012; OK/ERROR; banco o empleado)
--    Regla: si paga por ventanilla -> NRO_EMP con valor y NRO_BANCO NULL
--           si es débito automático -> NRO_BANCO con valor y NRO_EMP NULL
-- =========================================================
INSERT INTO PAGOS_CUOTAS_cn (NRO_OPE, COD_CUOTA, MONTO_PAGADO, FEC_HORA, ESTADO, NRO_BANCO, NRO_EMP)
VALUES
('P2001','C1001',1500.00,'2012-01-10 10:30:00','OK',   'B0001', NULL),   -- débito
('P2002','C1002',1600.00,'2012-02-12 09:45:00','OK',   NULL,    'E0001'), -- ventanilla
('P2003','C1003',1700.00,'2012-03-15 11:15:00','ERROR','B0002', NULL),   -- error - débito
('P2004','C1004',1800.00,'2012-04-20 14:00:00','OK',   NULL,    'E0002'), -- ventanilla
('P2005','C1005',1900.00,'2012-05-05 16:30:00','OK',   'B0003', NULL),   -- débito
('P2006','C1006',2000.00,'2012-01-22 10:10:00','ERROR',NULL,    'E0003'), -- error - ventanilla
('P2007','C1007',2100.00,'2012-07-28 13:25:00','OK',   'B0004', NULL),   -- débito
('P2008','C1008',2200.00,'2012-03-10 08:40:00','ERROR','B0005', NULL),   -- error - débito
('P2009','C1009',2300.00,'2012-03-02 12:00:00','OK',   NULL,    'E0004'), -- ventanilla
('P2010','C1010',2400.00,'2012-07-18 09:00:00','OK',   'B0006', NULL);   -- débito
GO

-- =========================================================
-- 7) ERRORES_POR_PAGO_cn (detalles para pagos con ESTADO='ERROR')
--    (P2003, P2006, P2008)
-- =========================================================
INSERT INTO ERRORES_POR_PAGO_cn (COD_ERROR, NRO_OPE, FEC_HORA)
VALUES
('E001','P2003','2012-03-15 11:16:00'),
('E002','P2003','2012-03-15 11:17:00'),
('E003','P2003','2012-03-15 11:18:00'),
('E004','P2006','2012-06-22 10:11:00'),
('E006','P2006','2012-06-22 10:12:00'),
('E007','P2006','2012-06-22 10:13:00'),
('E003','P2008','2012-08-10 08:41:00'),
('E009','P2008','2012-08-10 08:42:00'),
('E010','P2008','2012-08-10 08:43:00'),
('E002','P2008','2012-08-10 08:44:00');
GO


/*
select *
from ALUMNO_cn;

select *
from BANCO_cn;

select *
from CUOTA_cn;

select *
from EMPLEADOS_cn;

select *
from ERRORES_POR_PAGO_cn;

select *
from ESTADO_ERROR_cn;

select *
from PAGOS_CUOTAS_cn;

*/


/*
contactar a todas las personas registradas, 
tanto alumnos como empleados. Por lo que es necesario tener 
un listado con todos ellos, su número de teléfono y saber si es un alumno 
o un empleado. Genere el listado ordenado por Nombre
*/






































