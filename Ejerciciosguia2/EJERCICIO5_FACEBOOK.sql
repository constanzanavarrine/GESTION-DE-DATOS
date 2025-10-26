-- =========================================
-- Tablas base
-- =========================================
CREATE TABLE perfil (
    ID_perfil     CHAR(10)        NOT NULL,
    descripcion   VARCHAR(100)    NOT NULL,
    fecha_alta    SMALLDATETIME   NOT NULL,
    fecha_baja    SMALLDATETIME   NULL,
    CONSTRAINT pk_perfil PRIMARY KEY (ID_perfil)
);
GO

CREATE TABLE pais (
    ID_pais       CHAR(10)        NOT NULL,
    descripcion   VARCHAR(100)    NOT NULL,
    fecha_alta    SMALLDATETIME   NOT NULL,
    fecha_baja    SMALLDATETIME   NULL,
    CONSTRAINT pk_pais PRIMARY KEY (ID_pais)
);
GO

CREATE TABLE provincia (
    ID_pais       CHAR(10)        NOT NULL,
    ID_provincia  CHAR(10)        NOT NULL,
    descripcion   VARCHAR(100)    NOT NULL,
    fecha_alta    SMALLDATETIME   NOT NULL,
    fecha_baja    SMALLDATETIME   NULL,
    CONSTRAINT pk_provincia PRIMARY KEY (ID_pais, ID_provincia),
    CONSTRAINT fk_prov_pais
        FOREIGN KEY (ID_pais)
        REFERENCES pais (ID_pais)
);
GO

-- =========================================
-- Entidades de usuarios y relaciones
-- =========================================
CREATE TABLE usuario (
    user_name        CHAR(10)        NOT NULL,
    nombre           VARCHAR(50)     NOT NULL,
    apellido         VARCHAR(50)     NOT NULL,
    fecha_nacimiento SMALLDATETIME   NULL,
    fecha_ingreso    SMALLDATETIME   NOT NULL CONSTRAINT df_ingreso DEFAULT (GETDATE()),
    estado_civil     CHAR(15)        NOT NULL,
    cant_amigos      INT             NOT NULL,
    cant_pendientes  INT             NOT NULL,
    cant_rechazados  INT             NOT NULL,
    ID_pais          CHAR(10)        NULL,
    ID_provincia     CHAR(10)        NULL,
    mail_principal   VARCHAR(100)    NOT NULL,
    estado_muro      VARCHAR(1000)   NULL,
    fecha_baja       SMALLDATETIME   NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (user_name),
    CONSTRAINT ck_estado CHECK (estado_civil IN ('SOLTERO','CASADO','VIUDO','COMPROMETIDO','DIVORCIADO')),
    CONSTRAINT fk_usu_prov
        FOREIGN KEY (ID_pais, ID_provincia)
        REFERENCES provincia (ID_pais, ID_provincia)
);
GO

CREATE TABLE grupo (
    id_grupo     CHAR(10)       NOT NULL,
    nombre       VARCHAR(200)   NOT NULL,
    fec_ingreso  SMALLDATETIME  NOT NULL,
    fundacion    VARCHAR(100)   NOT NULL,
    ID_pais      CHAR(10)       NOT NULL,
    ID_provincia CHAR(10)       NOT NULL,
    informacion  TEXT           NULL,
    perfil       VARCHAR(500)   NOT NULL,
    ID_perfil    CHAR(10)       NOT NULL,
    mision       VARCHAR(500)   NOT NULL,
    sitio_web    VARCHAR(100)   NOT NULL,
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grup_prov
        FOREIGN KEY (ID_pais, ID_provincia)
        REFERENCES provincia (ID_pais, ID_provincia),
    CONSTRAINT fk_perfil
        FOREIGN KEY (ID_perfil)
        REFERENCES perfil (ID_perfil)
);
GO

CREATE TABLE usu_grup (
    id_grupo       CHAR(10)        NOT NULL,
    user_name      CHAR(10)        NOT NULL,
    fec_asignacion SMALLDATETIME   NOT NULL CONSTRAINT df_ug_ingreso DEFAULT (GETDATE()),
    fec_bloqueo    SMALLDATETIME   NULL,
    me_gusta       BIT             NULL,
    CONSTRAINT pk_usu_grup PRIMARY KEY (id_grupo, user_name),
    CONSTRAINT fk_ug_grup
        FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo),
    CONSTRAINT fk_ug_usu
        FOREIGN KEY (user_name)
        REFERENCES usuario (user_name)
);
GO

CREATE TABLE amistad (
    user_name         CHAR(10)        NOT NULL,
    user_name_amigo   CHAR(10)        NOT NULL,
    fec_solicitud     SMALLDATETIME   NOT NULL CONSTRAINT df_a_ingreso DEFAULT (GETDATE()),
    fec_aceptacion    SMALLDATETIME   NULL,
    fec_ignora        SMALLDATETIME   NULL,
    usuario_bloqueo   CHAR(10)        NULL,
    fec_bloqueo       SMALLDATETIME   NULL,
    CONSTRAINT pk_amistad PRIMARY KEY (user_name, user_name_amigo),
    CONSTRAINT fk_amigo1
        FOREIGN KEY (user_name)
        REFERENCES usuario (user_name),
    CONSTRAINT fk_amigo2
        FOREIGN KEY (user_name_amigo)
        REFERENCES usuario (user_name),
    CONSTRAINT fk_amigo3
        FOREIGN KEY (usuario_bloqueo)
        REFERENCES usuario (user_name)
);
GO





/* ============================
   INSERTS: TABLAS MAESTRAS
   ============================ */

-- PERFIL (15)
INSERT INTO perfil (ID_perfil, descripcion, fecha_alta, fecha_baja) VALUES
('PF01', 'Perfil Tecnología', GETDATE(), NULL),
('PF02', 'Perfil Arte', GETDATE(), NULL),
('PF03', 'Perfil Música', GETDATE(), NULL),
('PF04', 'Perfil Deportes', GETDATE(), NULL),
('PF05', 'Perfil Ciencia', GETDATE(), NULL),
('PF06', 'Perfil Literatura', GETDATE(), NULL),
('PF07', 'Perfil Cine', GETDATE(), NULL),
('PF08', 'Perfil Viajes', GETDATE(), NULL),
('PF09', 'Perfil Educación', GETDATE(), NULL),
('PF10', 'Perfil Gastronomía', GETDATE(), NULL),
('PF11', 'Perfil Historia', GETDATE(), NULL),
('PF12', 'Perfil Fotografía', GETDATE(), NULL),
('PF13', 'Perfil Programación', GETDATE(), NULL),
('PF14', 'Perfil Startups', GETDATE(), NULL),
('PF15', 'Perfil Gaming', GETDATE(), NULL);
GO

-- PAIS (15)
INSERT INTO pais (ID_pais, descripcion, fecha_alta, fecha_baja) VALUES
('PA01', 'Argentina', GETDATE(), NULL),
('PA02', 'Brasil', GETDATE(), NULL),
('PA03', 'Chile', GETDATE(), NULL),
('PA04', 'Uruguay', GETDATE(), NULL),
('PA05', 'Paraguay', GETDATE(), NULL),
('PA06', 'Perú', GETDATE(), NULL),
('PA07', 'Bolivia', GETDATE(), NULL),
('PA08', 'Colombia', GETDATE(), NULL),
('PA09', 'Ecuador', GETDATE(), NULL),
('PA10', 'México', GETDATE(), NULL),
('PA11', 'España', GETDATE(), NULL),
('PA12', 'Italia', GETDATE(), NULL),
('PA13', 'Francia', GETDATE(), NULL),
('PA14', 'Alemania', GETDATE(), NULL),
('PA15', 'Estados Unidos', GETDATE(), NULL);
GO

-- PROVINCIA (15) -> armamos 3 por país para PA01..PA05
INSERT INTO provincia (ID_pais, ID_provincia, descripcion, fecha_alta, fecha_baja) VALUES
('PA01','PR01','Buenos Aires',      GETDATE(), NULL),
('PA01','PR02','Córdoba',           GETDATE(), NULL),
('PA01','PR03','Santa Fe',          GETDATE(), NULL),

('PA02','PR01','São Paulo',         GETDATE(), NULL),
('PA02','PR02','Rio de Janeiro',    GETDATE(), NULL),
('PA02','PR03','Minas Gerais',      GETDATE(), NULL),

('PA03','PR01','Santiago RM',       GETDATE(), NULL),
('PA03','PR02','Valparaíso',        GETDATE(), NULL),
('PA03','PR03','Biobío',            GETDATE(), NULL),

('PA04','PR01','Montevideo',        GETDATE(), NULL),
('PA04','PR02','Maldonado',         GETDATE(), NULL),
('PA04','PR03','Canelones',         GETDATE(), NULL),

('PA05','PR01','Asunción',          GETDATE(), NULL),
('PA05','PR02','Central',           GETDATE(), NULL),
('PA05','PR03','Alto Paraná',       GETDATE(), NULL);
GO


/* ============================
   INSERTS: USUARIOS (15)
   ============================ */
-- Nota: omitimos fecha_ingreso para usar DEFAULT (GETDATE()).
INSERT INTO usuario (
    user_name, nombre, apellido, fecha_nacimiento, 
    estado_civil, cant_amigos, cant_pendientes, cant_rechazados,
    ID_pais, ID_provincia, mail_principal, estado_muro, fecha_baja
) VALUES
('USR0001','Ana','Lopez','1990-01-10','SOLTERO',0,0,0,'PA01','PR01','ana1@mail.com','Hola mundo',NULL),
('USR0002','Bruno','Martinez','1988-02-20','CASADO',0,0,0,'PA01','PR02','bruno2@mail.com',NULL,NULL),
('USR0003','Carla','Gomez','1992-03-15','VIUDO',0,0,0,'PA01','PR03','carla3@mail.com',NULL,NULL),
('USR0004','Diego','Suarez','1991-04-12','COMPROMETIDO',0,0,0,'PA02','PR01','diego4@mail.com','Viajando...',NULL),
('USR0005','Elena','Fernandez','1993-05-25','DIVORCIADO',0,0,0,'PA02','PR02','elena5@mail.com',NULL,NULL),
('USR0006','Fabian','Diaz','1994-06-30','SOLTERO',0,0,0,'PA02','PR03','fabian6@mail.com','Codeando',NULL),
('USR0007','Gabriela','Paz','1989-07-08','CASADO',0,0,0,'PA03','PR01','gabi7@mail.com',NULL,NULL),
('USR0008','Hector','Mendez','1990-08-18','SOLTERO',0,0,0,'PA03','PR02','hector8@mail.com','Música!',NULL),
('USR0009','Irene','Peralta','1995-09-22','DIVORCIADO',0,0,0,'PA03','PR03','irene9@mail.com',NULL,NULL),
('USR0010','Joaquin','Rivas','1991-10-28','SOLTERO',0,0,0,'PA04','PR01','joa10@mail.com','Corriendo',NULL),
('USR0011','Karen','Sosa','1992-11-11','CASADO',0,0,0,'PA04','PR02','karen11@mail.com',NULL,NULL),
('USR0012','Luis','Quiroga','1987-12-05','VIUDO',0,0,0,'PA04','PR03','luis12@mail.com','Cine',NULL),
('USR0013','Maria','Ibarra','1996-01-19','COMPROMETIDO',0,0,0,'PA05','PR01','maria13@mail.com',NULL,NULL),
('USR0014','Nicolas','Acosta','1993-02-14','SOLTERO',0,0,0,'PA05','PR02','nico14@mail.com','Fotos',NULL),
('USR0015','Olivia','Vega','1990-03-03','CASADO',0,0,0,'PA05','PR03','olivia15@mail.com',NULL,NULL);
GO


/* ============================
   INSERTS: GRUPOS (15)
   ============================ */
INSERT INTO grupo (
    id_grupo, nombre, fec_ingreso, fundacion,
    ID_pais, ID_provincia, informacion, perfil, ID_perfil, mision, sitio_web
) VALUES
('GRP0001','Tecno BA',GETDATE(),'2010','PA01','PR01','Grupo de tecnología BA','Perfil tech local','PF01','Innovar','http://tecno-ba.com'),
('GRP0002','Arte Cba',GETDATE(),'2015','PA01','PR02','Artistas de Córdoba','Artes visuales','PF02','Crear','http://arte-cba.com'),
('GRP0003','Música SF',GETDATE(),'2012','PA01','PR03','Bandas y recitales','Rock y más','PF03','Compartir','http://musica-sf.com'),
('GRP0004','Dev SP',GETDATE(),'2011','PA02','PR01','Programadores SP','Meetups y charlas','PF13','Aprender','http://dev-sp.com'),
('GRP0005','Rio Running',GETDATE(),'2016','PA02','PR02','Runners RJ','Entrenamientos','PF04','Superarse','http://riorun.com'),
('GRP0006','Minas Ciencia',GETDATE(),'2009','PA02','PR03','Divulgación científica','Café científico','PF05','Difundir','http://minasciencia.com'),
('GRP0007','Santiago Lectores',GETDATE(),'2013','PA03','PR01','Lecturas y debates','Club de lectura','PF06','Leer','http://stg-lectores.com'),
('GRP0008','Valpo Cine',GETDATE(),'2014','PA03','PR02','Cine y críticos','Ciclo de cine','PF07','Analizar','http://valpocine.com'),
('GRP0009','Biobío Viajes',GETDATE(),'2018','PA03','PR03','Tips y destinos','Mochileros','PF08','Explorar','http://biobioviajes.com'),
('GRP0010','Montevideo Edu',GETDATE(),'2008','PA04','PR01','Educadores UY','Capacitaciones','PF09','Enseñar','http://mvedu.com'),
('GRP0011','Maldonado Foodies',GETDATE(),'2017','PA04','PR02','Gastronomía uy','Recetas y reseñas','PF10','Degustar','http://mfoodies.com'),
('GRP0012','Canelones Historia',GETDATE(),'2011','PA04','PR03','Historia local','Charlas y salidas','PF11','Preservar','http://caneloneshistoria.com'),
('GRP0013','Asunción Startups',GETDATE(),'2019','PA05','PR01','Emprendedores PY','Networking','PF14','Escalar','http://asustart.com'),
('GRP0014','Central Foto',GETDATE(),'2020','PA05','PR02','Fotografía PY','Salidas fotográficas','PF12','Capturar','http://centralfoto.com'),
('GRP0015','AltoParaná Gaming',GETDATE(),'2021','PA05','PR03','Gamers PY','Torneos y LAN','PF15','Jugar','http://apgaming.com');
GO


/* ============================
   INSERTS: USU_GRUP (15)
   ============================ */
-- Dejo 15 memberships (uno por usuario/grupo, todos activos)
INSERT INTO usu_grup (id_grupo, user_name, fec_bloqueo, me_gusta) VALUES
('GRP0001','USR0001',NULL,1),
('GRP0002','USR0002',NULL,1),
('GRP0003','USR0003',NULL,1),
('GRP0004','USR0004',NULL,1),
('GRP0005','USR0005',NULL,1),
('GRP0006','USR0006',NULL,0),
('GRP0007','USR0007',NULL,1),
('GRP0008','USR0008',NULL,1),
('GRP0009','USR0009',NULL,1),
('GRP0010','USR0010',NULL,1),
('GRP0011','USR0011',NULL,0),
('GRP0012','USR0012',NULL,1),
('GRP0013','USR0013',NULL,1),
('GRP0014','USR0014',NULL,1),
('GRP0015','USR0015',NULL,1);
GO


/* ============================
   INSERTS: AMISTAD (15)
   ============================ */
-- Convención: amistad registrada por par (user_name, user_name_amigo).
-- Algunas aceptadas (fec_aceptacion), otras pendientes (solo solicitud), y 1 bloqueada.
INSERT INTO amistad (
    user_name, user_name_amigo, 
    fec_aceptacion, fec_ignora, usuario_bloqueo, fec_bloqueo
) VALUES
('USR0001','USR0002', GETDATE(), NULL, NULL, NULL),  -- aceptada
('USR0001','USR0003', NULL, NULL, NULL, NULL),       -- pendiente
('USR0002','USR0003', GETDATE(), NULL, NULL, NULL),  -- aceptada
('USR0002','USR0004', NULL, NULL, NULL, NULL),       -- pendiente
('USR0003','USR0004', GETDATE(), NULL, NULL, NULL),  -- aceptada
('USR0003','USR0005', NULL, GETDATE(), NULL, NULL),  -- ignorada
('USR0004','USR0005', GETDATE(), NULL, NULL, NULL),  -- aceptada
('USR0004','USR0006', NULL, NULL, NULL, NULL),       -- pendiente
('USR0005','USR0006', GETDATE(), NULL, NULL, NULL),  -- aceptada
('USR0005','USR0007', NULL, NULL, NULL, NULL),       -- pendiente
('USR0006','USR0007', GETDATE(), NULL, NULL, NULL),  -- aceptada
('USR0007','USR0008', NULL, NULL, NULL, NULL),       -- pendiente
('USR0008','USR0009', GETDATE(), NULL, NULL, NULL),  -- aceptada
('USR0009','USR0010', NULL, NULL, 'USR0009', GETDATE()), -- bloqueada por USR0009
('USR0011','USR0012', GETDATE(), NULL, NULL, NULL);  -- aceptada
GO




--PROCEDURES


/*
Genere un procedimiento que a partir de la 
descripción de un país (descripción), muestre un 
listado con la cantidad de usuarios activos por 
provincia (mostrar la descripción).

Aplicar procedimiento en todas las provincias, 
tengan o no usuarios


*/

-- descripcion del pais -> parametro 

create procedure pcd_usuarios_c_provincia(@descripcion VARCHAR(100)) 
as
begin
  
  set nocount on;
  
  select 
    pv.descripcion                                          as [Descripcion],
    sum(CASE WHEN us.fecha_baja IS NULL THEN 1 ELSE 0 END)  as [Cantidad usuarios activos]
  
  from pais ps
  join provincia pv     on pv.id_pais = ps.id_pais
  left join usuario us  on us.id_pais = pv.id_pais and us.id_provincia = pv.id_provincia 
  
  where pv.fecha_baja is NULL 
        and  ltrim(rtrim(ps.descripcion)) = ltrim(rtrim(@descripcion)) 
  
  group by pv.descripcion
  order by pv.descripcion;

end;
go

--Prueba 
declare @descripcion VARCHAR(100)    
set @descripcion = 'Argentina'
EXEC pcd_usuarios_c_provincia @descripcion;
GO

/*
1. Genere un procedimiento que a partir de un user name muestre 
un listado ordenado por nombre y apellido de los amigos activos. 
Además debe devolver la cantidad de amigos de ese user name.


2. Considere ejecutar ese procedure de la siguiente forma. 
Si la cantidad de amigos es 0 entonces debe mostrar una leyenda 
diciendo que no tiene amigos. En caso contrario mostrar 
la cantidad de amigos que tiene.

*/


CREATE PROCEDURE pcd_amistad(
    @username CHAR(10),
    @cantidad INT output)
    
as
begin
    set nocount on;
    
    /* 1) Listado de amigos activos ordenado por nombre y apellido */
    select 
      uam.nombre    as [Nombre],
      uam.apellido  as [Apellido],
      uam.user_name as [UserName_Amigo]
    
    from amistad a 
    join usuario us
          on us.user_name = a.user_name 
          and us.fecha_baja is NULL                 -- dueño activo 
    join usuario uam
          on uam.user_name = a.user_name_amigo      
          and uam.fecha_baja is NULL                -- amigo activo 
          
    where a.fec_aceptacion is not null              -- amistad aceptada -> es la unica señal positiva de que 
                                                    -- la relacion ya fue aceptada (efectivamente son amigos)
          and a.fec_bloqueo is null                 -- no bloqueada
          and a.fec_ignora is null                  -- no ignorada 
          and us.user_name = @username 
    
    order by uam.nombre, uam.apellido; 


    /* Cantidad de amigos activos (devuelta por OUTPUT) */
    select @cantidad = COUNT(*)
    from amistad a 
    join usuario us
        ON us.user_name = a.user_name 
        AND us.fecha_baja is NULL
    
    join usuario uam
          on uam.user_name = a.user_name_amigo      
          and uam.fecha_baja is NULL  
    where fec_aceptacion is NOT NULL
          and a.fec_bloqueo is null                 
          and a.fec_ignora is null                 
          and us.user_name = @username;

end;
go

--Prueba
declare @cant INT;
EXEC pcd_amistad @username = 'USR0001', @cantidad = @cant OUTPUT;

IF @cant = 0
  print 'No tiene amigos';
ELSE
  print 'La cantidad de amigos es: ' + CONVERT(VARCHAR(10), @cant);

go 



/*
1. Genere un procedimiento que actualice el campo me_gusta de 
la tabla usu_grup a falso si tiene fec_bloqueo no nula. 
Considere que el procedimiento se corre todas las noches y 
debe devolver la variable interna @@error para controlar 
la ejecución del update.

2. Ejecute el procedure y controle el valor de la variable @@error

*/

-- notemos que este stored procedure como se actualiza diariamente
-- no tiene un parametro de entrada 

-- "debe devolver" -> variable de salida: @@error

create procedure pcr_actualizar_likes 
as
begin 
    set nocount on;
    update usu_grup
    set me_gusta = 0        -- '0'→False porque type(me_gusta) = bit 
    where fec_bloqueo is not null
    
    return @@error

end;
go 



/*
1. Genere un procedimiento que a partir de un user name muestre un 
listado de todos los grupos a los que pertenece actualmente. 
De cada grupo mostrar la descripción del perfil, considerando que un 
grupo puede no tener perfil establecido.

2. Genere un procedimiento que muestre todos los grupos con sus perfiles. 
Considere mostrar también los grupos sin perfil y los perfiles que no 
tienen grupos asignados.
*/

create procedure prc_listado_grupos (@username CHAR(10))
as
begin 
  select 
      g.nombre         as [Nombre Grupo],
      pf.descripcion   as [Descripcion del Perfil] 
    --un grupo puede no tener perfil 
    
  from usu_grup ug
  
  join usuario us 
    on us.user_name = ug.user_name 
    and us.fecha_baja is null -- usuario activo
    
  join grupo g              
    on g.id_grupo = ug.id_grupo
    
  left join perfil pf       
    on pf.ID_perfil = g.ID_perfil
  
  where ug.user_name = @username 
    and ug.fec_bloqueo is NULL -- pertenece actualmente 
    
  order by [Nombre Grupo];
  

end;
go 

--Ejemplo de ejecucion
EXEC prc_listado_grupos 'USR0001';
go

CREATE PROCEDURE prc_grupos_y_perfiles
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        g.id_grupo,
        g.nombre         AS [Nombre del Grupo],
        pf.ID_perfil,
        pf.descripcion   AS [Descripcion del Perfil]
    FROM grupo g
    FULL JOIN perfil pf
        ON pf.ID_perfil = g.ID_perfil   -- muestra grupos sin perfil y perfiles sin grupo
    ORDER BY 1
END;
GO

-- Prueba
EXEC prc_grupos_y_perfiles;
go



-- TRIGGERS

/*
1) Crear un trigger para que cada vez que se inserta una amistad, 
se actualice la tabla del usuario que solicita la amistad como 
amistad pendiente.
*/
CREATE TRIGGER trg_new_follower
ON amistad
FOR INSERT
AS
BEGIN
    DECLARE @solicitante CHAR(10);

    SELECT @solicitante = user_name   -- << columna real de TU tabla AMISTAD
    FROM inserted;

    UPDATE usuario
    SET cant_pendientes = ISNULL(cant_pendientes, 0) + 1
    WHERE user_name = @solicitante;   -- << columna real de TU tabla USUARIO
END;
GO


/*
2) Crear un trigger para que cada vez que 
se acepta o bloquea una amistad, se actualice 
la tabla de ambos usuarios involucrados.
*/
CREATE OR ALTER TRIGGER tr_update_amistad
ON amistad
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

      /* 
       1) Actualización por aceptación de amistad
       */
    UPDATE usuario
    SET cant_amigos = cant_amigos + 1
    FROM usuario u
    INNER JOIN (
        SELECT i.user_name, i.user_name_amigo
        FROM inserted i
        INNER JOIN deleted d
            ON i.user_name = d.user_name
           AND i.user_name_amigo = d.user_name_amigo
        WHERE d.fec_aceptacion IS NULL   -- antes no estaba aceptada
          AND i.fec_aceptacion IS NOT NULL  -- ahora sí está aceptada
    ) AS cambios
        ON u.user_name IN (cambios.user_name, cambios.user_name_amigo);

     /* 
       2) Actualización por bloqueo de amistad
     */
    UPDATE usuario
    SET cant_amigos = CASE 
                         WHEN cant_amigos > 0 THEN cant_amigos - 1 
                         ELSE 0 
                      END,
        cant_rechazados = cant_rechazados + 1
    FROM usuario u
    INNER JOIN (
        SELECT i.user_name, i.user_name_amigo, i.usuario_bloqueo
        FROM inserted i
        INNER JOIN deleted d
            ON i.user_name = d.user_name
           AND i.user_name_amigo = d.user_name_amigo
        WHERE d.fec_bloqueo IS NULL     -- antes no estaba bloqueada
          AND i.fec_bloqueo IS NOT NULL -- ahora sí está bloqueada
    ) AS bloqueos
        ON u.user_name IN (bloqueos.user_name, bloqueos.user_name_amigo);

    IF @@ERROR <> 0
    BEGIN
        RAISERROR('Error al actualizar contadores de usuarios por cambio en amistad.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

  
/*
3)Crear un trigger que impida borrar el contenido de la tabla usuario.
*/
create trigger trg_not_delete_usuario
on usuario
for delete
AS
BEGIN
  raiserror('No se permite eliminar registros de la tabla usuario', 16, 1);
  rollback transaction 

end;
go 


/*
Suponga que en la tabla se agrega la columna “cantidad de grupos” 
a fin de contabilizar la cantidad de grupos a la que está asociado 
un usuario.


4) Escriba la sentencia para agregar esa columna.
*/
ALTER TABLE usuario
ADD cantidad_grupos INT NULL;
go 


/*
5) Crear un trigger para que cada vez que se inserta un nuevo 
registro en la tabla usu_grup, se actualice el campo que creo en el punto 7.
*/


CREATE TRIGGER trg_actualiza_cantidad_grupos
ON usu_grup
FOR INSERT
AS
BEGIN
  begin try
    declare @usuario CHAR(10)
    
    -- guardo el usuario que se inserto 
    select @usuario = user_name from inserted; 
    
    -- actualizo su contadores
    UPDATE usuario 
    set cantidad_grupos = isnull(cantidad_grupos, 0) + 1 
    where user_name = @usuario;
    
  end try
  begin catch
    rollback transaction
    raiserror('No se pudo realizar la ejecucion',16,1)
  end catch;
END;
go




/*
Genere un procedimiento que a partir de un user name devuelva 
un listado ordenado por nombre de los grupos activos.
*/

CREATE PROCEDURE prc_listado_grupos_activos (@username CHAR(10) )
AS
begin
  select 
    g.nombre as [Nombre Grupo]
  
  from usu_grup ug
  
  join usuario us 
    on us.user_name = ug.user_name 
    and us.fecha_baja is null -- usuario activo
    
  join grupo g              
    on g.id_grupo = ug.id_grupo
  
  where ug.user_name = @username 
        and ug.fec_bloqueo is null -- pertenece actualmente
  
  order by [Nombre Grupo];

end;
go 

  










