CREATE TRIGGER trg_nuevo_precio
ON historial_precio
FOR INSERT
AS 
BEGIN
    BEGIN TRY
        DECLARE @id_formacion INT 
        DECLARE @id_historial_precio INT
        DECLARE @nuevo_precio DECIMAL(10,2)

        SELECT
            @id_formacion = id_formacion,
            @id_historial_precio = id_historial_precio, 
            @nuevo_precio = precio
        FROM inserted 

        --Cerrar el preciio anterior activo 
        UPDATE historial_precio
        SET vigencia_hasta = GETDATE()
        WHERE id_formacion = @id_formacion AND vigencia_hasta IS NULL

        -- Actualizar el precio actual en formacion
        UPDATE formacion
        SET precio_actual = @nuevo_precio
        WHERE id_formacion = @id_formacion
    END TRY 
    BEGIN CATCH 
        ROLLBACK TRANSACTION
        RAISERROR('Error al actualizar el precio de la formacion y cerrar el historial anterior', 16, 1)
    END CATCH
END
go
