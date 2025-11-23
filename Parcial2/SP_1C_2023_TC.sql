--1)
ALTER TABLE USUARIO 
    ADD tipo_ingreso VARCHAR(15) NOT NULL DEFAULT 'T',  -- 'T' tarjeta, 'B' biometrico
    ADD fecha_registro_tajeta DATETIME NULL,
    ADD fecha_registro_biometrico DATETIME NULL;

ALTER TABLE USUARIO 
    ADD CONSTRAINT CK_registros 
    CHECK
    (fecha_registro_tajeta NULL or fecha_registro_biometrico NULL)
   

--2) 
-- INGRESO registra cada vez que el socio ingresa al natatorio 
-- validar ingreso_tarjeta e ingreso_biomedico 
-- esto lo hacemos a partir de la columna tipo_ingreso que agregamos anteriormente 

CREATE TRIGGER trg_ingreso_usuario
ON INGRESO
FOR INSERT 
AS
BEGIN 
    DECLARE 
        @id_usuario INT, 
        @fec_ingreso DATETIME,
        @ingreso_tarjeta BIT,
        @ingreso_biometrico BIT,
        @tipo_ingreso VARCHAR(15),
        @fecha_registro_tajeta DATETIME,
        @fecha_registro_biometrico DATETIME;
    

    -- Tomo los datos de las filas que se quiere insertar
    SELECT 
        @id_usuario = i.id_usuario, 
        @fec_ingreso = i.fec_ingreso,
        @ingreso_tarjeta = i.ingreso_tarjeta,
        @ingreso_biometrico = i.ingreso_biometrico
    FROM INSERTED i

    -- Cuando ingreso un registro se acepta
    -- si el usuario tiene biometria registrada -> acepta ingreso_tarjeta = 1 y se rechaza ingreso_tarjeta = 1
    -- si el usuario tiene tarjeta vigente -> acepta ingreso_tarjeta = 1 y ingreso_biometrico = 0
    -- si no se cumple nada de lo anterior -> levanta error y deshacce el insert 
    -- el trigger tiene que IMPEDIR LOS CASOS INVALIDOS 

    -- Tomo los datos auxiliares 
    SELECT 
        @tipo_ingreso = u.tipo_ingreso
    FROM USUARIO u
    WHERE u.id_usuario = @id_usuario;

    -- si el socio tiene el registro de sus datos biometricos, no seria posible 
    -- que ingrese utilizando su tarjeta 
    IF (@tipo_ingreso = 'B' AND @ingreso_tarjeta IS NOT NULL)
    BEGIN 
        RAISERROR('No puede usar trajeta si ya registro datos biometricos ',16,1);
        ROLLBACK TRANSACTION;
        RETURN;
    END; 
    ELSE IF(@tipo_ingreso = 'T' AND @ingreso_biometrico = 1)
    BEGIN 
    RAISERROR('No puede usar datos biometricos si no los ha registrado ',16,1);
    ROLLBACK TRANSACTION;
    RETURN;
    END; 
     
END;
GO


--procedure
CREATE PROCEDURE sp_fechas_emision_registros(
    @id_usuario INT,
    @error INT OUTPUT
)
AS 
BEGIN 
        SET NOCOUNT ON;

        DECLARE @year INT;
        SET @year = YEAR(GETDATE());

        select
             a.nombre_apellido,
             max(b.fec_emision) fecha
        from usuario a
        join registro_tarjeta b
        on a.id_usuario = b.id_usuario
        WHERE a.id_usuario = @id_usuario       -- usuario por parametro
            and a.fec_baja is null             -- usuario activo
            and b.fec_baja is null             -- tarjeta activa 
            and year(b.fec_emision) = @year    -- year en curso 
        group by a.nombre_apellido
            
        union
            
        select 
            a.nombre_apellido,
            max(b.fec_registro) fecha
        from usuario a
        join registro_biometrico b
        on a.id_usuario = b.id_usuario
        WHERE a.id_usuario = @id_usuario       -- usuario por parametro
            and a.fec_baja is null             -- usuario activo
            and year(b.fec_registro) = @year   -- year en curso
        group by a.nombre_apellido
        order by 1

        --Devolver el error
        SET @error = @@ERROR
END;
GO
        

DECLARE @err INT;
EXEC sp_fechas_emision_registros
     @id_usuario = 1
     @error = @err OUTPUT;

SELECT @err as CODIGO_ERROR


    
    
    

    

    
        

        
        
        

 









