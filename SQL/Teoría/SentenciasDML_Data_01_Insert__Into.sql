Como insertar registros?

## FORMA 1

insert [into] tabla (columna1, columna2, ...)
values (valor1, valor2, ...);

-- into es opcional, pero se recomienda usarlo para mejorar la legibilidad del codigo.
-- columna1, columna2, ... son los nombres de las columnas donde se insertaran los valores.
-- valor1, valor2, ... son los valores que se insertaran en las columnas correspondientes.


## FORMA 2
insert [into] tabla
values (valor1, valor2, ...);
-- en esta forma, se deben proporcionar valores para todas las columnas de la tabla,
-- en el mismo orden en que fueron definidas en la tabla.

## FORMA 3 CON SELECT
insert [into] tabla (columna1, columna2, ...)
select columnaA, columnaB, ...
from otra_tabla
where condicion;

columna1 = columnaA
columna2 = columnaB
-- esta forma permite insertar registros en una tabla a partir de los resultados
-- de una consulta SELECT en otra tabla.

-- Ejemplo:
insert into Empleados (Nombre, Apellido, Salario)
values ('Juan', 'Perez', 50000);
go

insert into Empleados
values ('Maria', 'Gomez', 60000);
go

insert into Empleados (Nombre, Apellido, Salario)
select Nombre, Apellido, Salario
from Candidatos
where Aceptado = 1;
go

-- En este ejemplo, se insertan tres registros en la tabla Empleados.
-- El primer registro se inserta especificando las columnas y los valores.
-- El segundo registro se inserta proporcionando valores para todas las columnas.
-- El tercer registro se inserta a partir de una consulta SELECT en la tabla Candidatos,
-- filtrando solo aquellos candidatos que han sido aceptados.

-- Ejemplo de la forma 3
INSERT INTO LLAMADOS (nro_reclamo, fecha)
    SELECT i.nro_reclamo, @fecha_ejecucion
    FROM INSERTED i
    JOIN CLIENTES c ON i.cliente = c.id_cliente
    WHERE UPPER(i.tipo) IN ('FUERA DE PRODUCCIÓN', 'FUERA DE SERVICIO')
      AND i.severidad IN (4, 5)
      AND i.empleado IS NOT NULL
      AND c.estrellas >= 540;