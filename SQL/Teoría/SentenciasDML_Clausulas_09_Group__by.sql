Group by
-> permite agregar valores 
-> combina registros con valores identicos
-> registros en grupos para calcular los valores de agregacion
-> para calcular estadisticas
-> combina filas similares y produce una UNICA fia de los resultados para CADA GRUPO
de filas que tengan los mismos valores, para cada columna incluida en la clausula
 

SELECT [columna, ...]
        funcion (columna), ...

FROM tabla
[WHERE condicion]
[GROUP BY columna, ...]
[ORDER BY columna [DESC], ...]
