create table comp_cabecera (id int primary key, fecha datetime not null, cuit varchar(11));
create table comp_detalle (id int, producto varchar(10), cantidad int, precio_unitario decimal(10,2), precio_total decimal (12,2));
select * from comp_cabecera
select * from comp_detalle

insert into comp_cabecera values (1, '2025-09-02 20:40', null)
insert into comp_cabecera values (2, '2025-09-02 18:18', '1234567')
insert into comp_cabecera values (3, '2025-09-02 19:19', '1234567')

insert into comp_detalle values (1, 'A', 1, 10.5, null)
insert into comp_detalle values (1, 'B', 2, 20, null)
insert into comp_detalle values (1, 'C', 1, 30, null)
insert into comp_detalle values (2, 'A', 10, 10.5, null)
insert into comp_detalle values (3, 'C', 20, 30, null)

update comp_detalle set precio_total = precio_unitario * cantidad;

update comp_detalle set cantidad = 5  where id = 1 and producto = 'A'

ALTER TABLE comp_detalle ADD precio_total_calculado AS isnull(cantidad * precio_unitario,0);
--1 
alter table comp_detalle add fecha_alta datetime null;
--2
update comp_detalle set fecha_alta = '1900-01-01'
--3
alter table comp_detalle alter column fecha_alta datetime not null;

select * from comp_detalle where precio_total_calculado <> precio_total
select * from comp_detalle

insert into comp_detalle (id, producto, cantidad, precio_unitario, fecha_alta) values (3, 'D', 20, 30, getdate() )

insert into comp_detalle 

select * from comp_detalle where id = 3
delete comp_detalle where id = 3 and producto = 'C'
select * from comp_detalle where id = 3

truncate table comp_detalle;

delete from comp_detalle;