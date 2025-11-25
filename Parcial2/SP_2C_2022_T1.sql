
/*
Crear la tabla llamados considerando que un reclamo puede relacionarse 1 o 0 llamados y 1 llamado puede relacionarse con 1 reclamo. 
La PK de esta nueva tabla es el número de reclamo. 
Además debe tener una fecha, un porcentaje de satisfacción positivo que admita 2 enteros y 
2 decimales y una fecha de revisión opcional. (0,75 puntos) 
*/

CREATE TABLE LLAMADOS(
        nro_reclamo               INT NOT NULL,
        fecha_llamado             DATETIME NOT NULL,
        porcentaje_satisfaccion   DECIMAL(10,2) NOT NULL,
        fecha_revision            DATETIME NULL,
        
        CONSTRAINT PK_nro_reclamo PRIMARY KEY(nro_reclamo),
        CONSTRAINT FK_nro_reclamo FOREIGN KEY(nro_reclamo) REFERENCES RECLAMO(nro_reclamo),
        CONSTRAINT CK_fechas_validas CHECK(fecha_llamado < fecha_revision OR fecha_revision is NULL),
        CONSTRAINT CK_nro_positivo CHECK(porcentaje_satisfaccion > 0)
        
        );



/*
Luego, aplique todas las modificaciones y/o validaciones necesarias 
para que cada registro de la tabla reclamos tenga un empleado o un servicio, 
pero no ambos al mismo tiempo
*/

ALTER TABLE RECLAMOS
  ADD CONSTRAINT CK_reclamos CHECK(empleado IS NULL and servicio IS NOT NULL 
                                OR empleado IS NOT NULL and servicio IS NULL)
                        


/*
La idea del gerente es ocuparse él mismo de la revisión de esos reclamos y es por ello que le solicita plantear 
los triggers necesarios para poder:
- mantener en la tabla llamados los reclamos cuya severidad es 4 o 5 y 
- cuyo tipo sea FUERA DE PRODUCCIÓN o FUERA DE SERVICIO. 
- Pero solo le interesan los reclamos de los clientes que tienen por lo menos 540 estrellas y que el 
reclamo sea sobre un empleado. 
- El registro de la tabla llamados debe contener únicamente el número de reclamo y 
la fecha en que se ejecuta el trigger.
*/

CREATE TRIGGER trg_revision_reclamos
ON RECLAMOS
FOR INSERT
AS
BEGIN 
      SET NOCOUNT ON;
      
      DECLARE 
            @nro_reclamo INT,
            @fecha_ejecucion DATETIME;


      BEGIN TRY 
          
            -- Asigno la fecha de ejecucion de trigger 
            SET @fecha_ejecucion = GETDATE()
            
            -- Tomo los valores insertados por reclamo 
            SELECT 
                @nro_reclamo = nro_reclamo
            FROM INSERTED 
            WHERE UPPER(tipo) IN ('FUERA DE PRODUCCION', 'FUERA DE SERVICIO'),
            AND (severidad = 4 or severidad = 5), 
            AND empleado is not null,              -- El reclamo es sobre un empleado
            AND cliente IN (SELECT                 -- IN porque un cliente puede tener varios reclamos (por el modelo logico)
                                id_cliente
                           FROM CLIENTE 
                           WHERE estrellas >= 540); --El cliente que hace el reclamo tiene por lo menos 540 estrellas
            
            
            IF @@error <> 0 
            BEGIN 
             INSERT INTO LLAMADOS VALUES(@nro_reclamo, @fecha_ejecucion, 9, NULL)
            END;
            
      END TRY;
  
      BEGIN CATCH
          RAISERROR('Error al insertar valores del llamado', 16, 1);
          ROLLBACK TRANSACTION;
          RETURN;
      END CATCH;
END;
GO
 
 
 
/*         

 Si quisiera generar un procedure que contenga al query anterior y 
 que además considere solo los reclamos cuya duración sea menor a n días, 
 definiendo n a través de un parámetro de entrada. 
 
Considere que la duración es la diferencia entre la fecha de inicio del reclamo y 
la fecha de resolución. 
Además, devolver si existió algún error al ejecutarse. Desarrolle el procedure que 
resultaría e indique un ejemplo de cómo ejecutarlo (1 punto) 

*/

CREATE PROCEDURE SP_top_clientes(
                  @n INT)
AS
BEGIN     
          DECLARE 
              @error INT

          SELECT TOP 1 
              UPPER(cli.nom_apellido), 
              estrellas = CASE WHEN cli.estrellas < 499 THEN "Standard"
              
          WHEN cli.estrellas IN ( 500, 501) THEN "Premium"
          ELSE "Superior" END, 
          COUNT(*) 
          FROM reclamos rec 
          JOIN clientes cli ON id_cliente = cliente 
          WHERE rec.fec_baja IS NULL 
          AND cli.fec_baja IS NULL 
          AND rec.empleado IS NULL 
          AND rec.fec_resolucion IS NOT NULL    -- me garantizo que el reclamo tenga fecha de resolucion
          AND DATEDIFF(day,rec.fec_inicio, rec.fec_resolucion)<@n  -- miro que la diferencia en dias sea menor 
                                                                  -- al nro de dias pasado por parametro
          GROUP BY cli.nom_apellido, cli.estrellas 
          ORDER BY 3 DESC 
          
          -- devolver el error
          RETURN @error;
          
          -- sin declarar arriba el error podria ser:
          -- RETURN @@ERROR;
END;
GO

DECLARE @err INT; 
EXEC @err = SP_top_clientes @n=7;

SELECT @err as CODIGO_ERROR;
GO 




















                        