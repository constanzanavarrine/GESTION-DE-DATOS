--- BAJA FORMACION TAG - FORMA I (USO DELETE)

CREATE TRIGGER trg_baja_tag
ON TAG 
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        DELETE FT
        FROM FORMACION_TAG FT
        JOIN deleted D ON D.id_tag = FT.id_tag

    END TRY
    BEGIN CATCH
        -- Si algo falla, revertimos todo
        ROLLBACK TRANSACTION;

        RAISERROR('Error al dar de baja relaciones de FORMACION_TAG', 16, 1);
        RETURN;
    END CATCH
END
go

--- BAJA FORMACION TAG - FORMA II (1)(USO con JOIN)
CREATE TRIGGER trg_baja_tag
ON TAG 
FOR UPDATE
AS
BEGIN 
    BEGIN TRY
        UPDATE FT
        SET FT.fecha_baja = getdate()
        FROM FORMACION_TAG FT INNER JOIN INSERTED I ON FT.id_tag = I.id_tag
        WHERE I.FECHA_BAJA IS NOT NULL
    END TRY

    BEGIN CATCH 
        ROLLBACK TRANSACTION
        RAISERROR ('Error al dar de baja relaciones de FORMACION_TAG', 16, 1);

    END CATCH

END 
go

--- BAJA FORMACION TAG - FORMA II (2)(USO con IN)
CREATE TRIGGER trg_baja_tag_in
ON dbo.TAG
AFTER DELETE
AS
BEGIN
    BEGIN TRY
        -- Baja lógica en la hija según los TAG eliminados
        UPDATE dbo.FORMACION_TAG
        SET fecha_baja = GETDATE()
        WHERE fecha_baja IS NULL
          AND id_tag IN (
              SELECT D.id_tag
              FROM deleted AS D
          );
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('Error al actualizar relaciones en FORMACION_TAG (IN)', 16, 1);
        RETURN;
    END CATCH
END
GO



--- BAJA FORMACION TAG - FORMA II (3)(USO con EXISTS)
CREATE TRIGGER trg_baja_tag_exists
ON TAG
AFTER DELETE
AS
BEGIN
    BEGIN TRY
        -- Baja lógica en la hija según los TAG eliminados
        UPDATE FT
        SET FT.fecha_baja = GETDATE()
        FROM FORMACION_TAG AS FT
        WHERE FT.fecha_baja IS NULL
          AND EXISTS (
              SELECT 1
              FROM deleted AS D
              WHERE D.id_tag = FT.id_tag
          );
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('Error al actualizar relaciones en FORMACION_TAG (EXISTS)', 16, 1);
        RETURN;
    END CATCH
END
GO
