
/*
1) Crear una tabla de comidas con un id, una descripción y 
una cantidad de calorías 
que tienen que ser numéricas positivas. 
Considerar que una comida puede encontrarse en varias dietas y 
una dieta considera varias comidas

*/
CREATE TABLE COMIDAS(
      id_comida INT NOT NULL,
      descripcion VARCHAR(50) NOT NULL,
      cant_calorias INT NOT NULL,
      fecha_alta DATETIME NOT NULL,
      fecha_baja DATETIME NULL,
      
      CONSTRAINT PK_id_comida PRIMARY KEY(id_comida), 
      CONSTRAINT CK_cantidad_positiva CHECK(cant_calorias >= 0),
      CONSTRAINT CK_fechas_validas CHECK(fecha_alta < fecha_baja OR fecha_baja IS NULL)

);

CREATE TABLE COMIDAS_POR_DIETA(
    id_comidas_dieta INT NOT NULL,
    id_comida INT NOT NULL,
    id_dieta INT NOT NULL, 
    fecha_alta NOT NULL,
    fecha_baja NULL,
    
    CONSTRAINT PK_id_comida_dieta PRIMARY KEY(id_comidas_dieta),
    CONSTRAINT FK_comida FOREIGN KEY(id_comida) REFERENCES COMIDAS(id_comida),
    CONSTRAINT FK_dieta FOREIGN KEY(id_dieta) REFERENCES DIETA(id_comida)
    
);



/*

Cuando se aprueba un nuevo pedido, se debe asignar una dieta de acuerdo 
al perfil adecuado al pedido. 

Por ejemplo, un pedido de un usuario hipertenso 
debería excluir todas las dietas que son para hipertensos. 

Es por ello que le 
solicita plantear los triggers necesarios para poder asignar la mejor dieta posible. 

Explique que triggers precisa para implementar esta disposición y desarrolle al menos 
uno que contenga una o más tablas auxiliares. Considere que existe siempre un perfil que 
se adapte al pedido enviado. (2 puntos) 

*/

/*
Se inserta un registro en la tabla pedido cada vez que el usuario genere una solicitud de viandas. 

Al insertarse el registro el campo aprobado es 0 (falso). 

Luego, el personal de la empresa controla que los datos personales ingresados del usuario 
sean correctos (mail, celular, etc) así como su pago (que queda fuera del alcance del examen).

 Si se encuentra todo en condiciones, el campo aprobado se actualiza a 1 (verdadero). 
 */
 

CREATE TRIGGER trg_asignacion_dieta
ON DIETA 
FOR UPDATE 
AS 
BEGIN 
      SET NOCOUNT ON;
      
      
      DECLARE 
            @aprobado_nuevo BIT,
            @aprobado_viejo BIT,
            @hipertenso_insertado,
            @diabetico_insertado, 
            @celiaco_insertado,
            @peso_insertado,
            @dieta_elegida INT;
      
      SELECT 
            @aprobado_viejo
      FROM deleted;
      
      SELECT 
            @pedido_actualizado = id,
            @aprobado_nuevo = aprobado, 
            @hipertenso_insertado = hipertenso,
            @diabetico_insertado = diabetico, 
            @celiaco_insertado = celiaco, 
            @peso_insertado = peso_actual
      FROM inserted;
      
      IF @aprobado_viejo = 0 and @aprobado_nuevo = 1
      BEGIN
            SELECT 
                  @dieta_elegida = id
            FROM DIETA
            WHERE perfil = (
                            SELECT id
                            FROM PERFIL 
                            WHERE hipertenso = @hipertenso_insertado,
                                AND diabetico = @diabetico_insertado,
                                AND celiaco = @celiaco_insertado,
                                AND @peso_insertado BETWEEN peso_desde AND peso_hasta,
                                AND fec_baja is not NULL
                            )
            AND fec_baja is not NULL
            
            IF @dieta_elegida IS NULL
            BEGIN 
                RAISERROR('Error al encontrar una dieta con dichas especificaciones', 16, 1)
                ROLLBACK TRANSACTION;
            END;
            
            
            UPDATE PEDIDO 
            SET dieta = @dieta_elegida
            WHERE id = @pedido_actualizado 
            
            
            IF @@error != 0
            BEGIN
                  RAISERROR('Error al actualizar el registro', 16, 1);
                  ROLLBACK TRANSACTION;
            END; 
      END;
END;
GO
        
 
 
 
/*
Explique su objetivo 
Cree en procedure a partir del mismo considerando 
Ingreso por parámetro de las distintas características del perfil (celiaco, diabético, etc)
Incluya solo los pedidos de aquellos usuarios activos 
Devuelva el promedio de los perfiles con esas características y 0 si no hay ninguno 
Ejecute el procedure generado en el punto anterior
*/



-- Como me dice "DEVUELVA" -> necesito un parametro de salida 


CREATE PROCEDURE SP_info_dietas(
                  @celiaco INT,
                  @diabetico INT,
                  @hipertenso INT,
                  @peso
                  @cantidad OUTPUT)
AS
BEGIN 
    
    SELECT 
        @cantidad = ISNULL(count(*), 0)
    FROM PERFIL
    WHERE 
        hipertenso = @hipertenso, 
        and diabetico = @diabetico,
        and celiaco = @celiaco,
        and @peso between peso_desde and peso_hasta, 
        and fec_baja is null;
    

    SELECT 
          d.nombre, 
          d.principal_caracteristica 
          
    from perfil p 
    join dieta d 
    on p.id = d.perfil 
    where exists (select 1 
                  from pedido p
                  JOIN usuario u
                      ON p.usuario = u.id
                  where pedido.dieta = d.id 
                        and pedido.aprobado = 1
                        and u.fec_baja IS NOT NULL)   -- garantizo que el usuario este activo 
          and p.fec_baja is null 
          and d.fec_baja is null
          and p.hipertenso = @hipertenso,
          and p.diabetico = @diabetico,
          and p.celiaco = @celiaco,
          and @peso BETWEEN p.peso_desde AND p.peso_hasta;

END 
go



DECLARE @celiaco INT,
        @diabetico INT,
        @hipertenso INT,
        @peso INT,
        @cantidad INT;
SET @celiaco = 1, @diabetico = 0, @hipertenso = 0, @peso = 75;
EXEC SP_info_dietas @celiaco, @diabetico, @hipertenso, @peso, @cantidad OUTPUT
          
          
      
          






















