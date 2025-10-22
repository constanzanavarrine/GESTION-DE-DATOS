--Creacion de trigger
---Forma I
CREATE TRIGGER nombre_trigger
ON tabla 
    FOR 
    INSERT | UPDATE | DELETE 
AS 
BEGIN 
    --Accciones a ejecutar
END;

---Forma II
CREATE TRIGGER nombre_trigger
{BEFORE | AFTER} {INSERT | UPDATE | DELETE}
ON nombre_tabla 
FOR EACH ROW
BEGIN 
    --Accciones a ejecutar
END;

----Explicacion de la sintaxis
-> for each row -> indica que el trigger se ejecuta por cada fila afectada 
-> begin ... end -> agrupa multiples sentencias dentro del trigger 





--Modificacion del trigger 
ALTER TRIGGER nombre 

--Eliminacion del trigger
DROP TRIGGER nombre



