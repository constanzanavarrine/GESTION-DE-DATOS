SELECT lname
    LEFT(lname,2) '2 primeras letras',
    RIGHT(lname,2) '2 ultimas letras',
    SUBSTRING(lname,3,2) '3ra y 4ta letra'

FROM employee
ORDER BY lname DESC


SELECT lname
    REVERSE(lname) 'al reves',
    REPLACE(lname,'O','a') 'nombre sin o',
    UPPER(lname) 'mayusculas'
    LOWER(lname) 'minusculas'

FROM employee
ORDER BY lname DESC

SELECT
    LTRIM('  Espacio Delante')
    RTRIM('Espacio Detras   ')
    LTRIM(RTRIM('  Espacio por todos lados    '))

SELECT
    LEN(LTRIM('  Espacio Delante')) as 'Sin espacio'
    LEN('  Espacio Delante') as 'Con espacio'


