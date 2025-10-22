insert into FACT_DET values (1, , , , ,), (1, , , , ,), (2, , , , ,), (2, , , , ,); 

insert into FACT_DET values (1, , , , ,); 

CREATE TRIGGER EJEMPLO_2_4_2
ON FACT_DET FOR INSERT
AS
BEGIN

begin try
	declare @id_cabecera int
	declare @total_insertado decimal(10,2)

	select @id_cabecera = id_cabecera, @total_insertado = precio * cantidad from inserted
	update fac_cab set total = total + @total_insertado where id = @id_cabecera
end try
begin catch
	raiserror('Error al intentar mantener consistencia de datos. Vamos a volver todo para atras', 16, 1)
	rollback transaction
end catch
/*
update fact_cab
set total = fact_cab.total + suma_cabecera.total_inserted
from fact_cab
join
	(
		select id_cabecera, sum(precio * cantidad) total_inserted
		from inserted
		group by id_cabecera
	) suma_cabecera
on  fact_cab.id = suma_cabecera.id_cabecera

update fact_cab
set total = fact_cab.total + (select  sum(isnull(precio,0) * isnull(cantidad,0)) from inserted where inserted.id_cabecera = fact_cab.id)
from fact_cab
where exists (select 1 from inserted where inserted.id_cabecera = fact_cab.id)
*/ 
END