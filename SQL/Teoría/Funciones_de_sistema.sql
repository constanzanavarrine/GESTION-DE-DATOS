SELECT
CASE
WHEN type = 'business' THEN 'Enviar a compras'
WHEN type = 'mod_cook' THEN 'Enviar a sotano'
WHEN type = 'popular_comp' THEN 'Enviar a ventas'
ELSE 'No enviar'
END
FROM titles


SELECT pub_id
CONVERT(INT, pub_id) as 'numerico'
FROM titles


SELECT hire_date
CONVERT(char(10), hire_date, 105) as 'otro_formato'
FROM employee
