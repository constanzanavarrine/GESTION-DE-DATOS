use borrar;

select * from EMPRESA;
select * from Herramienta;

update empresa 
set razon_social = 'naranja'
where cuil = '12345678901'

update Herramienta
set razon_emp = 'TE CAMBIO EL VALOR'

select * from EMPRESA;
select * from Herramienta;


select * from EMPRESA JOIN Herramienta ON EMPRESA.CUIL = Herramienta.cuil_empresa;

/*
insert into Herramienta values ('1', '12345678901', GETDATE(), 'pirulo')
insert into empresa values ('12345678901', 'rojo', 'av. santa fe 1234', '111');
insert into empresa values ('33345678900', 'azul', 'Libertad 45', '222');

*/