/*
Considerar que los productos se elaboran en base a distintas materias primas y los clientes 
realizan pedidos de productos. Para implementar la gestión de inventario se solicita:
     
 1) Crear una tabla SOLICITUD_REPOSICION que contenga código de solicitud, código de 
producto, cantidad, unidad de medida, procesada, fecha de alta y fecha de baja válida. 
Considere todas las restricciones que crea convenientes.
*/

CREATE TABLE SOLICITUD_REPOSICION(
    codigo_de_solicitud INT NOT NULL,
    codigo_de_producto  INT NOT NULL, 
    cantidad            INT NOT NULL,
    unidad_de_medida    CHAR(20) NOT NULL,
    procesada           BIT NOT NULL DEFAULT 1,    
    fecha_alta          DATETIME NOT NULL,
    fecha_baja          DATETIME NULL,

    CONSTRAINT pk_codigo_solicitud PRIMARY KEY(codigo_de_solicitud),
    CONSTRAINT fk_codigo_de_producto FOREIGN KEY(codigo_de_producto) REFERENCES PRODUCTO(Codigo),
    CONSTRAINT ck_fechas CHECK(fecha_alta < fecha_baja or fecha_baja is NULL),
    CONSTRAINT ck_cantidad CHECK(cantidad > 0)
    
);


/*
2) Para poder implementar el inventario de los productos, se debe agregar en 
    tabla PRODUCTOS los campos Stock_Inicial, Stock_Actual, Punto_Pedido y Genera_Pedido. 
    El último campo es un valor booleano mientras que el resto de los campos son numéricos 
    con valor 0 por default. Considerar Punto_Pedido como la cantidad mínima de stock que se 
    debe considerar para comenzar a elaborar más cantidad del producto. Se debe tener en cuenta 
    que stock actual y punto de pedido no pueden ser mayores a stock inicial y que todos son valores 
    positivos. Considere todas las restricciones que crea convenientes
*/

-- punto pedido: si el stock actual baja por debaj de este numero, tengo que generar un pedido
-- si punto_pedido = 0 -> "solo genero un pedido cuando el stock actual ya llego a cero" -> significa
-- que me quedo sin stock antes de reaccionar lo que genera incoscistencias en el inventario real
-- si fuera cero -> "esta permitido quedarme sin stock por completo antes de reponer" -> x

-- genero la tabla con los valores 
ALTER TABLE PRODUCTO
    ADD stock_inicial INT NOT NULL DEFAULT 0,
    ADD stock_actual  INT NOT NULL DEFAULT 0,
    ADD punto_pedido  INT NOT NULL DEFAULT 0,
    ADD genera_pedido BIT NOT NULL;

-- genero las reestricciones necesarias
-- 1) restriccion valor stock inicial y pedido
ALTER TABLE PRODUCTO 
    ADD CONSTRAINT CK_stock_relaciones 
        CHECK(stock_actual <= stock_inicial 
        and punto_pedido < stock_inicial);

-- 2) valores positivos
ALTER TABLE PRODUCTO 
    ADD CONSTRAINT CK_vpositivo 
    CHECK(stock_inicial>=0 
        and stock_actual>=0 
        and punto_pedido>0);


/*
De acuerdo con el objetivo de la empresa, cuando se registra un pedido, 
se deben actualizar los campos stock_actual y genera_pedido de la tabla producto 
a partir de las siguientes consideraciones:

a) El stock actual va a disminuir de 
acuerdo a la cantidad registrada en la tabla de pedido

b) Si el stock actual es menor, 
igual o hasta un 5% superior al punto de pedido, se debe registrar en el campo genera_pedido 
el valor “verdadero”, siempre y cuando ya no tenga registrado dicho valor. 

c) En caso de que el pedido del cliente se cancele, se debe actualizar el stock_actual y el 
campo genera_pedido según corresponda. 

Explique los triggers que precisa y desarrolle uno que utilice una o más tablas auxiliares.
*/




CREATE TRIGGER trg_registro_pedidos
ON DETALLE_PEDIDO
FOR INSERT -- el enunciado dice: "cuando se registre un pedido"
AS 
BEGIN 
    DECLARE 
        @ID_producto INT,
        @cantidad_solicitada INT;
        @stock_actual INT,
        @genera_pedido BIT,
        @punto_pedido INT,

    --1) tomo los datos del detalle insertado 
    --   (suponemos que el INSERT afecta solo una fila)
    SELECT
        @ID_producto         = i.ID_Producto,
        @cantidad_solicitada = i.cantidad_solicitada,
       
    FROM INSERTED i;

    --2) Leo la info del producto 
    SELECT 
        @stock_actual          = p.stock_actual,
        @genera_pedido         = p.genera_pedido,
        @punto_pedido          = p.punto_pedido,
        
    FROM PRODUCTO p
    WHERE p.ID_producto = @ID_producto;

    
    --3) Calculo el nuevo stock 
    -- Es importante este paso porque necesitamos el stock_actual antes y despues del update 
    SET @nuevo_stock = @stock_actual - @cantidad_solicitada; 

    --4) Actualizo el stock_actual 
    UPDATE PRODUCTO
    SET stock_actual = @nuevo_stock 
    WHERE ID_Producto = @ID_Producto;

    IF @@ERROR <> 0
    BEGIN 
        RAISERROR('Error al actualizar el stock del producto.',16,1)
        ROLLBACK TRANSACTION;
        RETURN;
    END; 


    IF @nuevo_stock >= @punto_pedido
        AND @nuevo_stock <= 1.05*(@punto_pedido)
        AND @genera_pedido = 0
   
    BEGIN TRY
        UPDATE PRODUCTO
        SET genera_pedido = 1
        WHERE ID_Producto = @ID_Producto;
    END TRY
    BEGIN CATCH
        RAISERROR('Error al actualizar genera_pedido', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END CATCH;

END;
GO


/*
b) Reescriba la query anterior para que se incluya en un procedure de la siguiente forma: 
a. Incluya sólo los productos que requieren de una solicitud de reposición al momento de ejecución del query 
b. Reciba por parámetro fecha desde y hasta para los pedidos de clientes y se utilice en el query 
c. Devuelva un parámetro con la fecha y hora del momento de ejecución 

c) Ejecute el procedimiento generado en el punto anterior.

*/
CREATE PROCEDURE sp_materias_primas_reposicion(
    @fecha_desde     DATE,
    @fecha_hasta     DATE, 
    @fecha_ejecucion DATETIME OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    --1) Seteo la fecha/hora de ejecucion
    SET @fecha_ejecucion = GETDATE();

    --2) Query principal 
    SELECT 
        mp.codigo, 
        COUNT(*) AS cantidad_usos
    FROM materia_prima mp
    INNER JOIN producto_composicion pc  
        ON pc.codigo_materia_prima = mp.codigo
    INNER JOIN producto p 
        ON p.codigo = pc.codigo_producto 
    INNER JOIN pedido_detalle pd
        ON pd.id_producto = p.codigo
    INNER JOIN pedido_cliente pcli
        ON pcli.id_pedido_cliente = pd.id_pedido_cliente
    WHERE pcli.fecha_baja IS NULL                             -- pedido activo
      AND pc.cantidad > 5                                     -- composiciones "importantes"
      AND p.genera_pedido = 1                                 -- solo productos que requieren reposicion
      AND pcli.fecha_pedido BETWEEN @fec_desde AND @fec_hasta   -- solo productos que 
    GROUP BY mp.codigo;
END;
GO

-- FORMA 1
DECLARE 
    @fecha_desde DATE, 
    @fecha_hasta DATE, 
    @fecha_ejec DATETIME
SET @fecha_desde = '1/1/2024', 
    @fecha_hasta = '1/2/2024'
EXEC sp_materias_primas_reposicion 
    @fecha_desde, 
    @fecha_hasta, 
    @fecha_ejec OUTPUT  

--FORMA 2
DECLARE @fec_ejec DATETIME;
EXEC sp_materias_primas_reposicion
     @fec_desde       = '2025-01-01',
     @fec_hasta       = '2025-12-31',
     @fecha_ejecucion = @fec_ejec OUTPUT;
SELECT @fec_ejec AS fecha_y_hora_de_ejecucion;

    

    

    
        

        
        
        

 









