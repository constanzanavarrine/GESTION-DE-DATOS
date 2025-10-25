VIEWS

-> tabla virtual que se crea a partir de una consulta SELECT.
-> no almacena datos, solo la consulta
-> representa el contenido generado por una query SELECT

Por que usarlas?
-> restringe el acceso a ciertas columnas o filas de una tabla
-> simplifica consultas complejas
-> genera independencia de datos (si cambia la tabla, la vista puede permanecer igual)

Sintaxis:
Creacion de una vista:

CREATE VIEW nombre_vista AS
    SELECT columna1, columna2, ...
    FROM tabla
    [UNION | UNION ALL | JOIN ...]
    WHERE condicion;
GO


DROP VIEW nombre_vista;

ALTER VIEW nombre_vista AS
    SELECT columna1, columna2, ...
    FROM tabla
    [UNION | UNION ALL | JOIN ...]
    WHERE condicion;
GO

consultar una vista:
SELECT * FROM nombre_vista; 
O
SELECT columna1, columna2 FROM nombre_vista WHERE condicion;



REGLAS PRACTICAS:
-> No se pueden usar ORDER BY en la definicion de la vista (a menos que se use TOP)
-> No se pueden usar vistas anidadas (una vista que use otra vista)
-> No se pueden usar funciones de agregacion (SUM, COUNT, AVG, MIN, MAX) en la definicion de la vista
-> No se pueden usar DISTINCT en la definicion de la vista
-> No se pueden usar subconsultas en la definicion de la vista
-> No se pueden usar TOP en la definicion de la vista (a menos que se use ORDER BY)


