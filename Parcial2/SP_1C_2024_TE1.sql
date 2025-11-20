---1)
create table ingresos
(
    id_ingreso int not null primary key,
    id_cli int not null,
    fecha_ingreso datetime not null,
    id_suscripcion int not null, 
)

alter table ingresos add constraint 
fk_ingresos_cliente foreign key (id_cli) references cliente(id_cliente);
--- osea referencia a la tabla cliente en el id_cliente 
go


alter table ingresos add constraint 
fk_ingresos_sc foreign key (id_suscripcion) references suscripcion(id_suscripcion);
go


alter table ingresos add constraint 
ch_ingresos_fecha check (fecha_ingreso > '2024-01-01') --- agregamos una condicion para fecha ingreso 
go


--- las dos maneras son validas (la de chat y esta para el tema de los constraints)


---2) 
alter table cliente add estado_actual varchar(20); 

alter table cliente add constraint
ck_cliente_estado_actual check (estado_actual in ('ACTIVO', 'INTERRUMPIDO', 'BAJA'));


---3)
--- Se deberian crear triggers que actualicen el campo estado_actual en funcion
--- de eventos sobre la tabla suscripcion o interrupcion_servicio 
--- Por ejemplo, un trigger que marque el cliente como INTERRUMPIDO cuando
--- se inserta una interrupcion activa, o como BAJA cuando la suscripcion finaliza


--- Caso de ejemplo

    declare @id_cliente int = 1234
    --- buscamos si el cliente esta activo HOY 
    if (exists 
    select * 
    from suscripcion 
    where id_cliente = @id_cliente
    and fecha_baja is null
    and fecha_inicio <= GETDATE()
    and fecha_fin >= GETDATE()
    )

    begin 
        update cliente set estado = 'ACTIVO' where id_cliente = @id_cliente

    --- las verificaciones son necesarias para que no se dispare el trigger si
    --- no se cumple alguna de estas 

---4) 
--- Escribir en palabras que trigger haria y hacer un de estos 

---5) 
--- A partir del siguiente query 
--- a_ explicar el objetivo
--- b_ desarrollar un procedure que contenga el query anterior 

CREATE PROCEDURE xxxx 
(
    @monto_desde decimal(10,2),
    @monto_hasta decimal(10,2) 
    @error_estado int output,
    @datetime_ejec datetime output

)

as 
begin 
    SELECT TOP 3 z.ID_cliente, DATEDIFF(day, y.fec_fin, y.fec_inicio)
    FROM cliente z
    JOIN suscripcion x
    ON z.ID_cliente = x.ID_cliente
    JOIN INTERRUPCION_SERVICIO y
    ON y.ID_suscripcion = x.ID_suscripcion

    JOIN TIPO_suscripcion ts
    on x.id_tipo_suscripcion = ts.id_tipo_suscripcion

    WHERE z.fec_baja IS NULL  --- el where es el que me permite fltrar
    AND x.fec_baja IS NULL
    AND y.Fec_fin < getdate()
    AND z.estado_actual in ('ACTIVO', 'INTERRUMPIDO')
    AND ts.valor_actual BETWEEN @monto_desde AND @monto_hasta
    ORDER BY 2 DESC

    set @error_estado = @@error --- -> solamente puedo poner esto porque la variable es tipo entero
    set @datetime_ejec = GETDATE()
end 
go 

declare @salidaSP int
declare @elerror int
declare @fecha datetime 

exec @salidaSP = xxxx(10.5, 20.5, @elerror out, @fecha out)


--- por default el stored procedure me devuelve un int 
--- en return del stored procedure unicamente un valor numerico 

--- trae los tres primeros clientes de la interrupcion que mas duro 
--- el dateiff me dice el tiempo de duracion
--- order by 2 -> indica que el resultado se ordena por la segunda expresion del SELECT 
    --- si el select tiene por ej. columna1, columna2 -> hace referencia a col2


--- en un procedure se pueden devolver solo errores 