/*
update empresa 
set razon_social = 'naranja'
where cuil = '12345678901'

inserted
('12345678901', 'naranja', 'av. santa fe 1234', '111');

delete
('12345678901', 'rojo', 'av. santa fe 1234', '111');

*/

CREATE TRIGGER EJEMPLO_2_Empresa
ON Empresa FOR UPDATE
AS
BEGIN
	declare @cuil char(11)
	declare @nombre_anterior varchar(250)
	declare @nombre_actualizado varchar(250)

	select @cuil = cuil from inserted
	select @nombre_anterior = razon_social from deleted
	select @nombre_actualizado = razon_social from inserted

	update Herramienta 
	set razon_emp = @nombre_actualizado
	where cuil_empresa = @cuil

END
