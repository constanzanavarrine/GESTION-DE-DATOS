EJEMPLO SELECT CON ALIAS POR CADA COLUMNA

Uso de AS -> asignar un alias a una columna o expresión en el resultado de la consulta.

select columna1 AS alias1, columna2 AS alias2
from tabla_o_vista
where condicion

  -> El alias es un nombre temporal que se utiliza para mejorar la legibilidad del resultado.
  
  -> No afecta el nombre real de la columna en la tabla o vista.

  
  OBSERVACION

  -> El uso de AS es opcional. Se puede omitir y simplemente escribir el alias 
  después del nombre de la columna.

  select columna1 alias1, columna2 alias2
  