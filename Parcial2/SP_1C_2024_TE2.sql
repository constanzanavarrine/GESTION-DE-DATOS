CREATE TABLE INGRESOS_CLIENTE(
    id_ingresos_cliente INT NOT NULL,
    id_client INT NOT NULL,
    id_suscripcion INT NOT NULL, 
    fecha_ingreso DATETIME NOT NULL,

    CONSTRAINT pk_ingresos_cliente PRIMARY KEY (id_cingresos_cliente)
    CONSTRAINT fk_ingcli_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(ID_cliente)
    CONSTRAINT fk_ingcli_suscripcion FOREIGN KEY (id_suscripcion) REFERENCES SUSCRIPCION(ID_suscripcion)
    
);


-- En dos sentencias
ALTER TABLE CLIENTE
ADD estado_actual VARCHAR(250) NOT NULL;

ALTER TABLE CLIENTE
ADD CONSTRAINT ck_posibles_estados 
CHECK(estado_actual IN ('ACTIVO', 'INTERRUMPIDO', 'BAJA'));


-- En una sentencia 
ALTER TABLE CLIENTE
ADD estado_actual VARCHAR(250) NOT NULL,
    CONSTRAINT ck_posibles_estados
    CHECK(estado_actual IN ('ACTIVO', 'INTERRUMPIDO', 'BAJA'));



/*
SUSCRIPCION 
id sucripcion
id cliente fk
id tipo susc fk
fec inicio
fec fin 
dias acceso
fec alta
fec baja 
*/



-- Trigger sobre INGRESOS_CLIENTE
-- El trigger se va a lanzar cada vez que realice un ingreso, entonces aca no voy a tener que
-- asignar un valor, sino chequear que este todo OK para que eso ingreso quede guardado
-- o sea -> lo que verifico son los posibles errores para ante eso lanzar un ROLLBACK transaction

CREATE TRIGGER trg_ingreso_cliente 
ON INGRESOS_CLIENTE
FOR INSERT 
AS 
BEGIN 
    DECLARE
        @estado_actual VARCHAR(250),
        @dias_acceso INT,
        @cantidad_ingresos INT,
        @id_cliente INT,
        @id_suscripcion INT,
        @fecha_ingreso DATETIME;

    -- Tomo los datos de la fila que se quiere insertar 
    SELECT 
        @id_cliente     = i.id_cliente,
        @id_suscripcion = i.id_suscripcion,
        @fecha_ingreso  = i.fecha_ingreso,

    FROM INSERTED i; -- suponemos un solo registro en el insert 

        
    -- Traigo estado_actual del cliente y dias_acceso de la suscripcion
    SELECT
        @estado_actual = c.estado_actual,
        @dias_acceso   = s.dias_acceso
    FROM CLIENTE c
    JOIN SUSCRIPCION s
        ON s.ID_cliente = c.ID_cliente
        AND s.ID_suscripcion = @id_suscripcion 
    WHERE c.ID_cliente = @id_cliente; 



    --1) Validar que la suscripcion no este en pauso / baja 
    IF (@estado_actual = 'INTERRUMPIDO' or @estado_actual = 'BAJA')
    BEGIN 
        RAISERROR('El cliente no puede ingresar: la suscripcion esta en pausa o baja', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;



    --2) Contar cuantos ingresos ya tiene este cliente para esta suscripcion 
    SELECT @cantidad_ingresos = COUNT(*)
    FROM INGRESOS_CLIENTE
    WHERE   id_cliente = @id_cliente 
        AND id_suscripcion = @id_suscripcion;


    -- OJO: este count incluye la fila recien insertada(porque el trigger es AFTER/FOR)
    -- Entonces, si supera dias_acceso, no permitimos el ingresos
    IF (@cantidad_ingresos > dias_acceso)
    BEGIN 
        RAISERROR('El cliente ya uso todos los dias de acceso de la suscripcion,', 16,1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO



--- procedure:
--- debe filtrar los estados del cliente sean activo o interrumpido


CREATE PROCEDURE sp_top3_clientes_interrumpidos(
    @monto_desde DECIMAL(10,2),
    @monto_hasta DECIMAL(10,2),
    @error       INT OUTPUT  -- variable interna del SP
    )
AS
BEGIN   
    SELECT TOP 3 
    z.ID_cliente, 
    DATEDIFF(day, y.fec_fin, y.fec_inicio) AS dias_interrupcion
    FROM cliente z
    JOIN suscripcion x
    ON z.ID_cliente = x.ID_cliente
    JOIN INTERRUPCION_SERVICIO y
    ON y.ID_suscripcion = x.ID_suscripcion
    WHERE z.fec_baja IS NULL                      -- cliente no dado de baja
    AND x.fec_baja IS NULL                        -- suscripcion no dado de baja
    AND y.Fec_fin < getdate()                     -- interrupcion ya finalizada
    AND estado_actual in ('ACTIVO', 'INTERRUMPIDO') -- filtro pedido
    AND x.monto BETWEEN @mondo_desde AND @monto_hasta -- suscripciones en rango de monto 
    ORDER BY dias_interrupcion DESC;

    -- Devolver el valor de @@ERROR
    SET @error = @@ERROR   -- gracias al OUTPUT, lo que @error tenga, se copia a @err

END;
GO


DECLARE @err INT; -- esta variable todavia no tiene valor (vale NULL)
EXEC sp_top3_clientes_interrumpidos
    @monto_desde = 500,
    @monto_hasta = 2000,
    @error = @err OUTPUT;   -- la variable error vale err, que puede ser modificada en el SP


-- como hacemos para ver el valor de @err?
-- con un SELECT
SELECT @err AS codigo_error; 

-- Si no hubo errores -> codigo_error muestra 0

/*
@error → parámetro OUTPUT dentro del SP
@err → variable afuera
El SP modifica @error,
SQL Server copia el valor final a @err cuando termina.
*/
