Como se actualizan registros?

UPDATE tabla
SET {columna = expresion | DEFAULT | NULL} {, columna = expresion | DEFAULT | NULL} {...}
[WHERE condicion];


-> tabla es el nombre de la tabla donde se van a actualizar los registros.

-> columna es el nombre de la columna que se va a actualizar.

-> expresion es el nuevo valor que se va a asignar a la columna.

-> DEFAULT asigna el valor por defecto definido para la columna.
-> NULL asigna un valor nulo a la columna.
-> Se pueden actualizar varias columnas separadas por comas.

-> WHERE es opcional. Si se omite, se actualizaran todos los registros de la tabla.
-> condicion es una expresion que filtra los registros que se van a actualizar.



------------------------------------------------------------------------------

DEFAULT

-> se puede usar:
    - UPDATE
    - INSERT
    - ALTER TABLE
    - CREATE TABLE


-> el motor pone en la columna el valor predeterminado qu la tabla tenga configurado
es decir, el valor definido en su DEFAULT CONSTRAINT
-> no calcula nada nuevo ni toma el ultimo valor de la columna, sino que invoca ese valor por defecto que
quedo registrado cuando se creo la tabla o se anadio la restriccion

-> si no tiene valor predeterminado, se pone NULL
-> si la columna no acepta NULL y no tiene valor predeterminado, se produce un error


-- EJEMPLO
ALTER TABLE dbo.Clientes
    ADD CONSTRAINT DF_Clientes_Estado DEFAULT ('Activo') FOR Estado;

UPDATE dbo.Clientes
SET Estado = DEFAULT
WHERE ClienteId = 42;
go

-- En este ejemplo, se agrega una restricción de valor predeterminado 'Activo' a la columna Estado
-- de la tabla Clientes. Luego, se actualiza el registro con ClienteId 42 para que su columna Estado
-- tome el valor predeterminado 'Activo'.
