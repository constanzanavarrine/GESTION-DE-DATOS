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
