PROCEDURE

-- Creacion

create PROCEDURE Nombre_Procedimiento (@parametro1 tipo_dato [OUTPUT], @parametro2 tipo_dato)
AS 
BEGIN
    -- Cuerpo del procedimiento
    -- Sentencias SQL
END


-- Modificacion 
alter PROCEDURE Nombre_Procedimiento (@parametro1 tipo_dato, @parametro2 tipo_dato)
AS
BEGIN
    -- Cuerpo del procedimiento modificado
    -- Sentencias SQL
END

-- Eliminacion 
drop PROCEDURE Nombre_Procedimiento
    -- Elimina el procedimiento almacenado

--------------------------------------------------------------------------------------------------
-- Explicacion de la sintaxis
parametro -> valor que el stored procedure espera recibir
          -> se definen entre parentesis en CREATE PROCEDURE y siempre 
          empiezan con @ 
          
tipo_dato -> tipo de dato del parametro (int, varchar, date, etc)
output-> indica que el parametro es de salida (con los corchetes declaramos que el parametro es opcional)

AS -> palabra clave que indica el inicio del cuerpo del procedimiento
BEGIN -> palabra clave que indica el inicio del bloque de sentencias SQL
END -> palabra clave que indica el final del bloque de sentencias SQL

--------------------------------------------------------------------------------------------------

OBS: 
-> la variable que este dentro del stored procedure va a trabajar dentro del mismo, no se puede usar fuera de el.
-> usamos variables que pueden usar el parametro que le pasamos al stored procedure
-> podemos tener varios parametros, separados por comas
-> los parametros pueden ser de entrada (input) o de salida (output)
-> si es de salida, se debe especificar OUTPUT despues del tipo de dato
-> los parametros de salida permiten devolver valores al llamar al procedimiento almacenado
-> los procedimientos almacenados pueden devolver conjuntos de resultados, no solo valores individuales


--------------------------------------------------------------------------------------------------
-- Ejemplo de stored procedure que devuelve un listado 
create PROCEDURE listado_empleados 
AS BEGIN

SELECT UPPER(fname) FirstName, UPPER(lname) LastName   -- no se modifica el contenido de la tabla, sino que nos sirve para visualizacion
                                                        -- select lista atributos y le da un orden consecutivo a esos campos 
FROM Employees
WHERE fec_baja IS NULL
ORDER BY 1 -- quiere decir que ordene por la primer columna del select (en este caso por el nombre alfabetico)
END
GO


EXEC listado_empleados -- llamamos al procedimiento almacenado, es indispensable para que se ejecute el procedure
GO 

-----------------------------------------------------------------------------------

Diferencia entre stored procedure y trigger:
- Un stored procedure es un conjunto de instrucciones SQL que se almacenan en la base de datos y se pueden ejecutar de manera explícita cuando se desee.
- Un trigger es un tipo especial de procedimiento almacenado que se ejecuta automáticamente en respuesta a ciertos eventos en la base de datos, como inserciones, actualizaciones o eliminaciones de datos.
- Los stored procedures se invocan manualmente mediante una llamada explícita, mientras que los triggers se activan automáticamente en respuesta a eventos específicos.
- En el caso del procedures, si hay un error en la ejecucion, se devuelve un valor Nulo 
- En el procedure hablamos de acciones entonces no hace falta realizar de rollback
- En el trigger con el rollback cancelamos la transaccion 
--------------------------------------------------------------------------------------------------
Una buena practica es no usar alter procedure, sino drop y create, para evitar errores de sintaxis
DROP PROCEDURE IF EXISTS listado_empleados; -- el procedure puede no tener parametros 
CREATE PROCEDURE listado_empleados
AS BEGIN
    SELECT UPPER(fname) FirstName, UPPER(lname) LastName -- con el select solo estoy haciendo una consulta
    FROM Employees
    ORDER BY 1
END

-----------------------------------------------------------------------------------
-- Ejemplo de stored procedure con parametros
- necesito que trabaje como valor de filtrado
DROP PROCEDURE IF EXISTS listado_empleados
go
CREATE PROCEDURE listado_empleados (@pub char(4)) -- el parametro es de entrada (input) por defecto
AS BEGIN
    SELECT UPPER(fname) FirstName, UPPER(lname) LastName 
    FROM Employees
    WHERE pub_id = @pub -- uso el parametro para filtrar  
END
go 

-- forma dinamica de llamar al procedure
-- DENTRO DEL PROCEDURE NO SE PUEDE USAR DECLARE NI SET
-- DECLARACION PARA QUE ENTRE AL PROCEDURE
DECLARE @pub_id char(4) -- la declaracion de la variable siempre es antes del EXEC y debe llamarse de igual manera que donde esta el where 
SET @pub_id = '0736'    -- pongo la variable de forma manual 
EXEC listado_empleados @pub_id


---explicacion
-> el parametro pub es creado en el momento de creacion del procedure
-> entra a la query en forma dinamica
-> en la declaracion se le asigna un valor antes de llamar al procedure
-> luego, llamo al procedure y le paso como parametro el valor que tiene la variable


-------------------------------------------------------------------------------
--Ejemplo de stored procedure que devuelve un valor como argumento 
DROP PROCEDURE listado_empleados
go
CREATE PROCEDURE listado_empleados (@pub char(4), @max_lvl tinyint OUTPUT)
AS BEGIN

SELECT @max_lvl = max(job_lvl)
FROM employee
WHERE pub_id = @pub
END
go


DECLARE @pub_id char(4), @job_lvl tinyint
SET @pub_id = '0877'
EXEC listado_empleados @pub_id, @job_lvl OUTPUT

SELECT @job_lvl 'Maximo Job Level'
GETDATE() 'Dia de hoy'



-- select no tiene from porque estoy consultando un valor guardado en memoria 

-----------------------------------------------------------------------------------
--Ejemplo SP con control de errores TRY.. CATCH

CREATE PROCEDURE InsertarAlumno
    @Nombre NVARCHAR(100)
    @Carrera NVARCHAR(50)

AS
BEGIN
    BEGIN TRY
        INSERT INTO Alumnos(Nombre, Carrera) values (@Nombre, @Carrera);
    
    END TRY
    BEGIN CATCH 
        PRINT 'ERROR al insertar alumno:' + ERROR_MENSAJE();
    END CATCH
END 


