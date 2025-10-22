SELECT

-- Sirve para consultar los datos de una base de datos. 

select * -- {TOP/DISTINCT} columna o expresion [alias]
from tabla_o_vista
where condicion


* -> seleccionar todas las columnas de la tabla o vista especificada. 

  -> Esto es útil cuando queremos obtener todos los datos sin tener que enumerar 
    cada columna individualmente.

  -> En consultas más complejas o en tablas con muchas columnas,
    es recomendable especificar solo las columnas necesarias para mejorar el rendimiento y
    la legibilidad de la consulta.


-----------------------------------------------------------------------------------

select columna1, columna2, columna3
from tabla_o_vista
where condicion

  -> Seleccionar columnas específicas de una tabla o vista.

  -> Esto es útil cuando solo necesitamos ciertos datos y no toda la información disponible.



