CREATE TRIGGER EJEMPLO_2_Herramienta
ON Herramienta FOR UPDATE
AS
BEGIN
	declare @id int
	declare @cuil_empresa varchar(250)
	declare @nombre_empresa varchar(250)

	select 
		@id = Id_Herramienta,
		@cuil_empresa = cuil_empresa
		from inserted

	select @nombre_empresa = razon_social
	from EMPRESA where CUIL = @cuil_empresa

	update Herramienta
	set razon_emp = @nombre_empresa
	where @id = Id_Herramienta
END