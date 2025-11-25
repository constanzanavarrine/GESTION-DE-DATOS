
/*

Cada comisaría trabaja en conjunto con 2 a 3 hospitales. 
Existe una línea directa entre  ellos. Puede ocurrir que, 
en el momento de una llamada, el operador solicite la asistencia  
de un hospital o podría suceder que el operador lo solicite posteriormente 
cuando la  unidad policial lo requiera. Cree los objetos necesarios para 
reflejar esta situación en su  modelo (1,50 puntos)  

Queda fuera del modelo el registro de que vehículo de bomberos y/o 
ambulancias  asistieron al llamado, solo se debe registrar que cuartel 
de bomberos y/o hospital intervino  en la emergencia. 

*/



-- Genero la tabla hospital y su relacion con comisaria

CREATE TABLE HOSPITAL(
            id_hospital INT NOT NULL,
            id_comisaria INT NOT NULL,
            fecha_alta DATETIME NOT NULL,
            fecha_baja DATETIME NULL
            
            CONSTRAINT PK_id_hospital PRIMARY KEY(id_hospital),
            CONSTRAINT FK_comisaria_hospital FOREIGN KEY(id_comisaria) REFERENCES COMISARIA(nro_comisaria),
            CONSTRAINT CK_fechas_validas CHECK(fecha_alta < fecha_baja or fecha_baja IS NULL)
            );


-- Como en un llamado se puede solicitar la asistencia de un HOSPITAL
-- necesitamos anadir el campo hospital a la tabla LLAMADAS

ALTER TABLE LLAMADOS
ADD hospital INT NULL; 


/*

Ante un llamado que involucre situaciones que 
involucran a niños, niñas y adolescentes, se  activa un 
protocolo de minoridad que actúa bajo una resolución provista 
por el Ministerio  de Seguridad de la Nación. En ese sentido, 

- el campo protocolo_minoridad debe estar  activo si la edad reportada es menor a 18 años. 
- Posteriormente se completa la fecha y  hora en la que se contacta al responsable del niño, 
niña o adolescente (campo  fec_hora_resp_minoridad).  

- Validar la completitud de ambos campos de acuerdo a la edad reportada

*/

-- Supongo que protocolo de minoridad es del tipo bit -> si esta activo -> protocolo_minoridad = 1
ALTER TABLE LLAMADOS
    ADD CONSTRAINT CK_protocolo_edad CHECK((edad_reportada < 18 and protocolo_minoridad = 1 and fec_hora_resp_minoridad is not null)
    -- chequeo que si la edad es menor a 18 anios el protocolo esta activo y el campo fecha no esta vacio 
                                          or (EDAD <= 18 AND protocolo = 1 AND fec_hora_resp_minoridad IS NULL) -- Puede que se haya activado y la fecha no este cargada
                                          or (EDAD > 18 AND protocolo = 0 AND fecha IS NULL) -- Caso adultu no aplica protocolo
                                          or (EDAD is null AND protocolo is null AND fecha is null) -- Se inserto la llamada pero no hay datos cargados
);

    



/*
Suele suceder que, en zonas situadas en los límites de una provincia, 
la llamada de  emergencia se realice a la provincia vecina debido a la 
proximidad de la comisaría. En tales  casos, la provincia que atendió 
la situación debe enviar el costo incurrido a la provincia  desde la 
cual se originó la llamada. De esta manera, al actualizar la fecha y hora de  
resolución en la tabla de llamadas, se verifica si el tiempo de resolución excede a una hora.  

Si es así, se asigna al campo costo_inter_prov el resultado de multiplicar la cantidad de  
horas que tomó resolver la llamada por el costo hora de la unidad policial que acudió al  
llamado. 

Explique que trigger/s precisa para implementar esta disposición y 
desarrolle al  menos uno que contenga una o más tablas auxiliares.
*/


CREATE TRIGGER trg_emergencia
ON LLAMADAS
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE 
            @cod_llamada          INT,
            @horas_resolucion     INT,
            @cod_prov_origen      INT,
            @cod_prov_atendio     INT,
            @costo_hora           DECIMAL(10,2);

        -- Tomo los datos de la fila actualizada (asumimos 1 sola fila)
        SELECT 
            @cod_llamada      = i.cod_llamada,
            @horas_resolucion = DATEDIFF(HOUR, i.fec_hora, i.fec_hora_resuelto),
            @cod_prov_origen  = bo.cod_provincia,   -- provincia del barrio_reportado
            @cod_prov_atendio = bc.cod_provincia,   -- provincia de la comisaría/unidad
            @costo_hora       = u.costo_hora
        FROM inserted i
        JOIN BARRIOS bo           ON bo.codigo = i.barrio_reportado
        JOIN UNIDAD_POLICIAL u    ON u.nro_comisaria       = i.nro_comisaria
                                  AND u.nro_unidad_policial = i.nro_unidad_policial
        JOIN COMISARIAS c         ON c.nro_comisaria = u.nro_comisaria
        JOIN BARRIOS bc           ON bc.codigo = c.barrio
        WHERE i.fec_hora_resuelto IS NOT NULL;

        -- Si demoró más de 1 hora Y es interprovincial, calculo el costo
        IF @horas_resolucion > 1
           AND @cod_prov_origen <> @cod_prov_atendio
        BEGIN
            UPDATE LLAMADAS
            SET costo_inter_prov = @horas_resolucion * @costo_hora
            WHERE cod_llamada = @cod_llamada;
        END

        -- Opcional: tabla auxiliar de registro
        /*
        INSERT INTO COSTOS_INTERPROV_LOG
            (cod_llamada, prov_origen, prov_destino, horas, costo, fec_registro)
        VALUES
            (@cod_llamada, @cod_prov_origen, @cod_prov_atendio,
             @horas_resolucion, @horas_resolucion * @costo_hora, GETDATE());
        */

    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg, 16, 1);
    END CATCH;
END;
GO
         

/*


 Construya un procedure que  
a. Muestre las 10 llamadas que mayor duración de resolución tuvieron. 

b. Además, muestre la descripción del motivo del llamado, la cantidad de minutos de  
resolución, el nombre y apellido del operador que atendió el llamado (mostrarlos  unidos por 
un espacio entre nombre y apellido), el nombre de la comisaría y el  número de unidad policial. 

c. Los registros se limitan a un rango de fechas que se ingresan como parámetros y  se utilizan para filtrar la fecha y hora del llamado.  
d. Ejecute el procedure (2 puntos) 
    
*/

CREATE PROCEDURE SP_top10_llamados
    @fecha_inicial DATETIME,
    @fecha_fin     DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 10
        l.cod_llamada,
        ml.descripcion AS motivo_llamado,
        DATEDIFF(MINUTE, l.fec_hora, l.fec_hora_resuelto) AS minutos_resolucion,
        CONCAT(op.nombre, ' ', op.apellido) AS operador,
        c.nombre AS nombre_comisaria,
        up.nro_unidad_policial
    FROM LLAMADAS l
    JOIN MOTIVO_LLAMADA ml
        ON ml.cod_motivo = l.cod_motivo          -- ajustá este nombre si en tu modelo se llama distinto
    JOIN OPERADORES_TELEFONICOS op
        ON op.legajo = l.legajo
    JOIN UNIDAD_POLICIAL up
        ON up.nro_comisaria       = l.nro_comisaria
       AND up.nro_unidad_policial = l.nro_unidad_policial
    JOIN COMISARIAS c
        ON c.nro_comisaria = l.nro_comisaria
    WHERE l.fec_hora BETWEEN @fecha_inicial AND @fecha_fin
      AND l.fec_hora_resuelto IS NOT NULL
    ORDER BY DATEDIFF(MINUTE, l.fec_hora, l.fec_hora_resuelto) DESC;
END;
GO


-- Forma 1 ejecucion
DECLARE @fecha_inicial DATETIME = '2024-07-01',
        @fecha_fin     DATETIME = '2025-06-12';

EXEC SP_top10_llamados @fecha_inicial, @fecha_fin;
GO


--Forma 2 ejecucion
DECLARE @fecha_inicial DATETIME,
        @fecha_fin     DATETIME;

SET @fecha_inicial = '2024-07-01';
SET @fecha_fin     = '2025-06-12';

EXEC SP_top10_llamados @fecha_inicial, @fecha_fin;
GO



        




