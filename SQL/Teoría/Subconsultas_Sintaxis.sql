SUBCONSULTAS -> consulta dentro de otra
                -> no siempre devuelve un valor pues puede devolver un listado de valores
                -> la subconsulta debe devolver una sola columna (no se permiten múltiples columnas en el SELECT de la subconsulta en la cláusula WHERE)

SELECT
    expresion1, ...

FROM TABLA 
WHERE expresion operador(SELECT expresion1,
                            ...
                        FROM tabla)
go


para que me devuelva una sola condicion
-> where
-> top1 
-> funcion de agregacion



---------------------
Futbolistas |
ID |
Apellido |
Salario_anual |

--- Messi
--- Paso 1: saber cuanto gana messi
--- Paso 2: cuantos ganan mas que paso 1

SELECT 
FROM FutbolistasWHERE SALARIO > (SELECT SALARIO_ANUAL 
                                FROM FURBOLISTAS
                                WHERE APELLIDO = 'MESSI')

