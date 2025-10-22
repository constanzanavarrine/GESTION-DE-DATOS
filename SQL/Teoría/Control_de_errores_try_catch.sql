BEGIN TRY
--Codigo que puede fallar
END TRY
BEGIN CATCH
    -- Codigo para manejar el error
    SELECT ERROR_NUMBER() AS NumeroError, ERROR_MESSAGE() AS MensajeError;

END CATCH


-- Sintaxis general de RAISERROR
RAISERROR('mensaje', severidad, estado)

1. 'mensaje'  → el texto que se mostrata cuando se produzca el error

2. severidad(16)  → indica la gravedad del error (un numero entre 0 y 25)
0-10 → mensajes informativos, no son errores reales.

11-16 → errores que puede manejar el usuario o el programador.

17-25 → errores más graves, del servidor o sistema (solo puede generarlos un administrador).

En este caso 16 significa: “Error controlado del usuario, causado por la aplicación o por datos inválidos”.
Es el nivel más común dentro de un trigger o procedimiento.

3. estado(1)  → codigo interno o numero de etapa, usado para 
distinguir en que parte del codigo ocurrio el error
    - se usa 1 por defecto 