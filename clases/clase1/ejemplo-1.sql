--apuntes de select basico

select [columna]
    funcion (columna)

from table

[where condicion]
[group by columna,..]
[order by columna [DESC],..]


SELECT 
MAX(price) 'Maximo'
MIN(price) 'Minimo'
AVG(price) 'Promedio'
SUM (price) 'Suma Total'

--ejemplo usando count
SELECT COUNT(*) as 'Total Populares' -- con el asterisco miramos todos los registros
FROM titles
WHERE TYPE = 'popular_comp'

--ejemplo usando count sobre columnas 
SELECT COUNT(price)
    as 'Precios populares'
FROM titles
WHERE TYPE 

--ejemplo de diferencias con null

--aca los casos con null no los considera cuando hacemos valores e agregacion
-- -> LOS QUE TIENEN VALORES COMPLETOS
SELECT AVG(price) as 'Precios populares'
FROM titles
WHERE TYPE = 'popular_comp'
go

--- a los nulos le asignamos precio cero
--- -> mas alla de que no tengamos precios para sumar, los contamos en cantidad
--- porque ahoa tienen precio cero 
SELECT AVG(ISNULL(price,0))
FROM titles
WHERE TYPE = 'popular_comp'


SELECT COUNT(*) as 'Total Populares'
FROM titles
WHERE TYPE = 'popular_comp'

--EJEMPLO--
select *
from cocinero
select avg(edad)
select avg(isnull(edad,0))--> aca el promedio es mas chico porque consideramos a los nulos como cero 

-- cuantos cocineros son argentinos
select count(*)
from cocinero
where nacionalidad = 'argentino'

--
cantidad de personas de las que tenemos registro edad COMPLETOS
--

select sum(edad) suma_edad, count(edad) cant_edad, sum(edad)/count(edad) as prom, avg(edad) as prom
from cocinero

select TYPE
    sum(price) as sum_price
FROM titles
group by type 


-- para funciones de agregacion necesitamos agrupar--
select nacionalidad,avg(edad) as prom
from cocinero
where nacionalidad='argentino' --where siempre va antes del group by
group by nacionalidad
having avg(edad) = 22

-- cuando no salta nada es porque ningun dato es compatible con
-- lo que estamos pidiendo (porque no encuentra ninguna instancia)

-- USO DE LA CLAUSULA HAVING
select [columna]
    funcion


SELECT TYPE
    sum(price) as sum_price
FROM titles
GROUP BY type
HAVING SUM(price) > 30500


------------
JOIN
-------------

