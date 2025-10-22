CREATE TRIGGER trg_update_cantidad_docentes
ON DOCENTE_COMISION
FOR INSERT
AS
BEGIN
    BEGIN TRY
        DECLARE 
            @id_comision INT
        
        SELECT
            @id_comision = id_comision
        FROM inserted 

        UPDATE C
        SET C.cantidad_docentes = C.cantidad_docentes + 1
        FROM COMISION C INNER JOIN INSERTED I ON C.id_comision = i.id_comision

    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR ('Error al actualizar la cantidad de docentes en la comision',16,1)
    END CATCH

END
go



