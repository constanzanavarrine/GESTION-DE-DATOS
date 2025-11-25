
/*
Agregar la tabla promoción con un identificador 

único que será la pk, una fecha, una descripción opcional y 

un monto que admita dos decimales y sea positivo. 

Generar una relación opcional con alquiler, estableciendo 

que una promoción puede estar en 0 o muchos alquileres y 

un alquiler puede tener asociado 1 o 0 promoción (0,75 puntos) 
*/ 


CREATE TABLE PROMOCION(
        
        id_promocion  INT NOT NULL,
        id_alquiler   INT NOT NULL, 
        fecha_promocion DATETIME NOT NULL,
        descripcion VARCHAR(250) NULL,
        monto_promocion DECIMAL(10,2) NOT NULL
        
        
        CONSTRAINT PK_id_promocion PRIMARY KEY(id_promocion),
        CONSTRAINT FK_id_alquiler FOREIGN KEY(id_alquiler) REFERENCES ALQUILER(id_alquiler),
        CONSTRAINT CK_valor_positivo CHECK(monto_promocion >= 0)
        );
  

/*
 Luego, aplique todas las modificaciones y/o 
 validaciones necesarias para que cada registro 
 de la tabla alquiler tenga una cabaña o un 
 departamento, pero no ambos al mismo tiempo
 */ 
 
ALTER TABLE ALQUILER 
  ADD CONSTRAINT CK_unico_valor CHECK((cabania is NULL and depto is not NULL) 
                                   OR (cabania is not NULL and depto is NULL));


/*
Para poder contabilizar la antigüedad de los clientes,
el dueño estableció que se debe considerar los registros de la tabla alquiler.

Es decir, para saber que antigüedad tiene un cliente, se debe tomar el año 
de la fecha de inicio del alquiler y por cada año distinto, se suma 1 año a la antigüedad.

Por ejemplo, si usted cuenta con las siguientes fechas de inicio de alquiler 
para un cliente dado: 10/7/2005, 12/12/2005, 4/7/2007 y 8/7/2009, entonces la antigüedad será 3, 
que equivale a 3 años distintos en los cuales el cliente se hospedó en el complejo. 

Además se debe verificar que el alquiler fue realmente concretado (columna concretado tipo bit de la tabla alquiler). 
*/

CREATE TRIGGER trg_antiguedad_cliente
ON ALQUILER
FOR INSERT 
AS BEGIN 
      
      BEGIN TRY
        SET NOCOUNT ON;

        DECLARE 
            @id_alquiler  INT,
            @id_cliente   INT,
            @anio_inicio INT,
            @concretado   BIT,

        
        
        SELECT 
            @id_alquiler = id_alquiler,
            @id_cliente  = id_cliente,
            @anio_inicio = year(fecha_inicio),
            @concretado = concretado 
        FROM INSERTED 
        
        
        -- Solo si el alquilerq quedo realmente concretado 
        IF @concretado = 1 
        AND NOT EXISTS(
                      SELECT 1    -- al menos 1 
                      FROM ALQUILER 
                      WHERE id_cliente = @id_cliente 
                      AND concrentado = 1 
                      AND YEAR(fecha_inicio) = @anio_inicio
                      AND id_alquiler <> @id_alquiler) -- Esto chequea que no exista otro alquiler concretado del mismo cliente el mismo anio 
        
        BEGIN 
          
          -- El ano es nuevo para ese cliente: incremento la antiguedad 
          UPDATE CLIENTE
          SET antiguedad = antiguedad + 1 
          WHERE id_cliente = @id_cliente
        
        END; 
        
      END TRY;
      BEGIN CATCH
          RAISERROR('Error al actualizar registros del cliente', 16,1);
          ROLLBACK TRANSACTION;
          RETURN;
      END CATCH;
END;
GO


/*
Si quisiera generar un procedure que contenga al query anterior 
y que además considere solo los alquileres cuya duración sea menor a 
n días, definiendo n a través de un parámetro de entrada. Considere que la duración 
es la diferencia entre la fecha de inicio y la fecha de fin del alquiler. 
Además, devolver si existió algún error al ejecutarse. 
Desarrolle el procedure que resultaría e indique un ejemplo de cómo ejecutarlo (1 punto)
*/

SELECT TOP 1 
    UPPER(cli.nom_ape), 
    antiguedad = CASE 
                    WHEN cli.antiguedad <= 3 THEN 'Standard'
                    WHEN cli.antiguedad IN (4, 5) THEN 'Premium'
                    ELSE 'Superior'
                 END, 
    COUNT(*)
FROM alquiler alq
JOIN clientes cli ON alq.id_cliente = cli.id_cliente 
WHERE fec_fin > getdate() 
  AND cli.fec_baja IS NULL 
GROUP BY cli.nom_ape, cli.antiguedad 
ORDER BY 3 DESC















