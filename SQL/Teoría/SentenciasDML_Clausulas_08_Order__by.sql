select * | {top/distinct} columna o expresion [alias]
from tabla_o_vista
[where condicion]
[order by columna [asc|desc]]

--------------------------------------------------------------------------------------------------
-> desc se agrega a una columna para ordenar los resultados en orden descendente (de mayor a menor).
->  Si no se especifica, el orden predeterminado es ascendente (de menor a mayor).

--------------------------------------------------------------------------------------------------
[] {} -> Indican que el elemento es opcional.
   -> [] se usa para agrupar elementos opcionales.
   -> {} se usa para indicar que se debe elegir uno de los elementos dentro de las llaves.

/ -> Indica que se puede usar uno u otro elemento, pero no ambos al mismo tiempo.


--------------------------------------------------------------------------------------------------
--EJEMPLO

select nom, tipo_empl, fecha_nac
from empleados
where tipo_empl not in ('ADM', 'VEND')
order by fecha_nac, nom;

-- aca ordenamos segun fecha_nac en orden ascendente (por defecto) y si hay fechas iguales, 
--se ordena por nom en orden ascendente (por defecto).