- Las funciones de agregacion son:
    hacemos calculo respecto a 0 o mas filas 
    - SUM
    - MAX
    - MIN
    - AVG
    - COUNT



-- Ejemplos MAX, MIN, AVG, SUM 
SELECT MAX(price) 'Maximo'
        MIN(price) 'Minimo'
        AVG(price) 'Promedio'
        SUM(price) 'Suma Total'

FROM TITLES

-- Ejemplo usando count 
SELECT COUNT(*) as 'Total Populares'
FROM titles 
WHERE TYPE = 'popular_comp'

--Ejemplo usando count sobre columnas 
SELECT COUNT(price) as 'Precios Populares'
FROM titles
WHERE TYPE = 'popular_comp'

--Ejemplo de diferencias con NULL
# caso 1 sin NULL
--- aca los casos con null no los considera cuando hacemos valores de agregacion
--- considera los que tienen valores completos
SELECT AVG(price) as 'Precios Populares'
FROM titles
WHERE TYPE = 'popular_comp'
go

# caso 2 con NULL
--- a los nulos le asignamos precio cero
--- mas alla de que no tengamos precios para sum, los contamos en cantidad porque ahora 
--- dispusimos que el precio es cero 
SELECT AVG(ISNULL(price,0)) as 'Precios Populares'
FROM titles 
WHERE TYPE = 'popular_comp'


SELECT COUNT(*) as 'Total Populares'
FROM titles 
WHERE TYPE = 'popular_comp'

--Ejemplo con SUM y GROUP BY
SELECT type, 
    SUM(price) as sum_price
FROM titles
GROUP BY type 
    --> obtenemos la suma de los precios de la tabla titles por tipo 
    --> o sea me va a aparecer una columna que sea tipo y otra que sea sum_price con cada valor calculado 