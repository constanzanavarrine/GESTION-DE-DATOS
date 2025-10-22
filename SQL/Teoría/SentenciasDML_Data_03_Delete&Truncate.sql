Como borrar los registros?

delete tabla [where condicion];

-> tabla es el nombre de la tabla donde se van a borrar los registros.

truncate table tabla;

-------------------------------------------------------------------------
DIFERENCIA ENTRE DELETE Y TRUNCATE

-> DELETE permite borrar registros especificos utilizando la clausula WHERE.
   - Si no se especifica una condicion, se borran todos los registros de la tabla.

-> TRUNCATE borra todos los registros de una tabla de manera rapida y eficiente.
    - No permite filtrar registros, y no se puede usar con la clausula WHERE.


----------------------------------------------------------------------------

--EJEMPLO

DELETE usuario
WHERE usuario_id = 10;
go

'''
 delete statement conflicted with column reference constraint "fk_grupo"
 the conflict ocurred in database 'pubs', table 'grupo', column 'id_usuario'.
 the statement has been terminated.
 '''
-- En este ejemplo, se intenta borrar el registro con usuario_id 10 de la tabla usuario.
-- Sin embargo, si existen registros en la tabla grupo que hacen referencia a este usuario
-- a traves de una clave foranea (fk_grupo), se produce un error y no se puede completar la operacion de borrado.

-> para evitar este error, se debe asegurar que no existan referencias a este usuario en otras tablas
   antes de intentar borrarlo, o se deben eliminar primero esas referencias.
