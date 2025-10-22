SP_HELP PERSONA
PERSONA
o Administrador (arc)
o Cliente

PERSONA
# TipoDocumento ('DNI', 'PASAPORTE', 'CI')
# NroDocumento
* Apellido
o Localidad

CREATE TABLE PERSONA (
    TipoDocumento VARCHAR(20) NOT NULL,
    NroDocumento VARCHAR(20) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Edad INT NULL,
    Domicilio NVARCHAR(200) NULL,
    Localidad NVARCHAR(100) NULL,
    CONSTRAINT PK_PERSONA PRIMARY KEY (TipoDocumento, NroDocumento),
    CONSTRAINT CK_TipoDocumento CHECK (TipoDocumento IN ('DNI', 'PASAPORTE', 'CI')),
    CONSTRAINT CK_FechaNacimiento CHECK (FechaNacimiento <= CAST(GETDATE() AS DATE)),
	CONSTRAINT CK_Edad CHECK (Edad IS NULL OR Edad >= 0)
);

ALTER TABLE PERSONA ADD EdadCalculada AS DATEDIFF(YEAR, FechaNacimiento, GETDATE());
ALTER TABLE PERSONA DROP CONSTRAINT CK_Edad;
ALTER TABLE PERSONA DROP COLUMN Edad;
ALTER TABLE PERSONA ALTER COLUMN Localidad NVARCHAR(100);

-- DROP TABLE PERSONA;

INSERT INTO PERSONA 
/*
           ([TipoDocumento]
           ,[NroDocumento]
           ,[Nombre]
           ,[Apellido]
           ,[FechaNacimiento]
           ,[Domicilio]
           ,[Localidad])
*/
     VALUES
           ('DNI' -- <TipoDocumento, varchar(20),>
           ,'123ABC' -- <NroDocumento, varchar(20),>
           ,'JUAN' -- <Nombre, nvarchar(100),>
           ,'PP' -- <Apellido, nvarchar(100),>
           ,'1990-09-01'
           ,NULL
           ,DEFAULT
		   );
INSERT INTO PERSONA 
([Nombre],[Apellido],[TipoDocumento],[NroDocumento],[FechaNacimiento])
VALUES
('MARIA', 'ABC', 'PASAPORTE', '123ABC', '2000-09-01');

INSERT INTO PERSONA 
([Nombre],[Apellido],[TipoDocumento],[NroDocumento],[FechaNacimiento])
VALUES
('DOLORES', 'DEF', 'PASAPORTE', '456DEF', '2010-09-01');

INSERT INTO PERSONA 
([Nombre],[Apellido],[TipoDocumento],[NroDocumento],[FechaNacimiento])
VALUES
('FLORENCIA', 'XYZ', 'PASAPORTE', '78989', '2010-09-01');


-- 1
SELECT * FROM PERSONA;
UPDATE PERSONA SET Localidad = 'CABA', NUMERO = NUMERO + 1 where TipoDocumento = 'DNI'
SELECT * FROM PERSONA;

INSERT INTO PERSONA 
([Nombre],[Apellido],[TipoDocumento],[NroDocumento],[FechaNacimiento], NUMERO)
VALUES
('SANTIAGO', 'XYZ', 'DNI', '12345', '1980-01-01', DEFAULT);

UPDATE PERSONA SET Localidad = Nombre where TipoDocumento = 'DNI'

-- UPDATE PERSONA SET Numero = 123 where TipoDocumento = 'DNI'

UPDATE PERSONA SET Localidad = 'N/A' --  WHERE TipoDocumento = 'PASAPORTE'

-- 2
SELECT [TipoDocumento]
           ,[NroDocumento]
           ,[Nombre]
           ,[Apellido]
           ,[FechaNacimiento]
           ,[Domicilio]
           ,[Localidad] FROM PERSONA;




