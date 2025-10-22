Funciones de tiempo
 

SELECT 
    DAY('2017-04-28') as 'Dia'
    MONTH('2017-04-28') as 'Mes'
    YEAR('2017-04-28') as 'Ano'

→ reciben un argumento
→ devuelven un valor

SELECT
    DATEPART(WEEK,'2017-04-28') as 'Nro de Semana'          -- 18
    DATENAME(MONTH, '2017-04-28') as 'Nombre del mes'       -- Abril
    DATEDIFF(DAY, '2017-04-28','2017-12-24') as 'Cuantos dias faltan para nochebuena'    --240
