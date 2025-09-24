# GESTION-DE-DATOS

Group by = permite agregar valores  
    --> combina registros con valores identicos     
    --> registros en grupos para calcular los valores de agregacion     
    --> para calcular estadisticas 

Funciones de agregacion     
SUM     
AVG 
MAX     
MIN     
COUNT   

Count --> para cantidades totales 

'*' -> lo que indica son las instancias 


Having = permite filtrar grupos de filas    
siempre se usa con funcion de agregacion    

para limitar --> usamos WHERE--> es una condicion sobre el SELECT --> NO PERMITE CONDICION CON FUNCION DE AGREGACION 
para limitar solo aquellos paises donde el promedio sea mayor a 20 --> HAVING --> condicion sobre el GROUP BY   


## Como se relacionan?
![alt text](image-1.png)

* con id categoria    
## JOIN     
--> vincular una o mas tablas mediante uno o mas campos    
--> para tener combinaciones 
--> vuinculamos cada tabla de acuerdo a la # FK
--> FK que nos dice? que no puedo poner un valor que no exista en la tabla padre
--> mas alla de tener campos vacios voy a querer saber el lugar de origen 
--> entonces que nos permite? --> ver # todos los registros # tengan o no relacion

### INNER JOIN  
-> resultado de A que se relacione con B (Campos o claves mediante las que se vinculan)

![alt text](image-2.png)

![alt text](image-3.png)

* a partir de ahora involucramos mas de una tabla 
![alt text](image-4.png)

* puede que no todos los registros tengan relacion 

### LEFT [OUTER] JOIN   
--> prioridad de la izquierda 
* traer todo lo que esta a la izquierda sin importar lo que en este caso tenga categoria 

![alt text](image-5.png)

--> o sea aca hay dos cocineros que no tienen categoria (NULL) pero los muestra igual 


### RIGHT [OUTER] JOIN 
--> mostrame todas las categorias independiente de si se relaciona con el cocinero o no 

![alt text](image-6.png)


### FULL [OUTER] JOIN 
--> combinacion total de todo (right,left,inner)

### CROSS
--> lo que hace es un producto cartesiano
--> no busca FK


```sql

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


```

