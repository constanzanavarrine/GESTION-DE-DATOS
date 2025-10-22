HAVING
-> permite filtrar grupos de filas segun el resultado de una funcion de agregacion
-> siempre se usa con una funcion de agregacion
-> establece las condiciones para los grupos formados por GROUP BY 


--sintaxis

SELECT  [columna,...]
        funcion (columna), ...

FROM tabla
[WHERE condicion]
[GROUP BY columna, ...]
[HAVING condicion-funcion]
[ORDER BY columna [DESC], ...]

---Ejemplo 1

SELECT type, 
        SUM(price) as sum_price

FROM titles 
GROUP BY type
HAVING SUM(price) > 30500

---Ejemplo 2
-- para funciones de agregacion necesitamos agrupar--
select nacionalidad,avg(edad) as prom
from cocinero
where nacionalidad='argentino' --where siempre va antes del group by
group by nacionalidad
having avg(edad) = 22

-- cuando no salta nada es porque ningun dato es compatible con
-- lo que estamos pidiendo (porque no encuentra ninguna instancia)

-- En el group by va todo lo que esta en el select que no sea funcion de agregacion
-- Ejemplo 3
SELECT CL.NOMBRE
COUNT(*) AS CANTIDAD 




