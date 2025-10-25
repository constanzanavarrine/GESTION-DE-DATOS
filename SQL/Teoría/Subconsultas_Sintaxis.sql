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
FROM Futbolistas
WHERE SALARIO > (SELECT SALARIO_ANUAL 
                                FROM FURBOLISTAS
                                WHERE APELLIDO = 'MESSI')



-- En WHERE (filtrar por conjunto)
SELECT a.LEGAJO, a.NOM_Y_APE
FROM ALUMNO_cn a
WHERE a.LEGAJO IN (
  SELECT c.LEGAJO
  FROM CUOTA_cn c
  JOIN PAGOS_CUOTAS_cn p ON p.COD_CUOTA = c.COD_CUOTA
  WHERE YEAR(p.FEC_HORA) = 2012
);


--En SELECT (valor calculado)
SELECT 
  a.LEGAJO,
  (SELECT SUM(p.MONTO_PAGADO)
   FROM CUOTA_cn c
   JOIN PAGOS_CUOTAS_cn p ON p.COD_CUOTA = c.COD_CUOTA
   WHERE c.LEGAJO = a.LEGAJO) AS [Total Pagado]
FROM ALUMNO_cn a;

-- En FROM (tabla derivada)
SELECT x.Mes, x.MontoTotal
FROM (
  SELECT MONTH(FEC_HORA) AS Mes, SUM(MONTO_PAGADO) AS MontoTotal
  FROM PAGOS_CUOTAS_cn
  GROUP BY MONTH(FEC_HORA)
) AS x
WHERE x.MontoTotal > 5000;

-- EXISTS (verifica existencia de filas)
SELECT a.LEGAJO, a.NOM_Y_APE
FROM ALUMNO_cn a
WHERE EXISTS (
  SELECT 1
  FROM CUOTA_cn c
  WHERE c.LEGAJO = a.LEGAJO AND c.MONTO_TOTAL > 1000
);

-- HAVING (filtrar grupos)
SELECT c.LEGAJO, SUM(c.MONTO_TOTAL) AS TotalCuotas
FROM CUOTA_cn c
GROUP BY c.LEGAJO
HAVING SUM(c.MONTO_TOTAL) > (
  SELECT AVG(MONTO_TOTAL)
  FROM CUOTA_cn
);



-- Correlacionadas (subconsulta depende de la consulta externa)
SELECT a.LEGAJO, a.NOM_Y_APE
FROM ALUMNO_cn a
WHERE a.LEGAJO IN (
  SELECT c.LEGAJO
  FROM CUOTA_cn c
  WHERE c.MONTO_TOTAL > (
    SELECT AVG(MONTO_TOTAL)
    FROM CUOTA_cn
    WHERE LEGAJO = a.LEGAJO
  )
);