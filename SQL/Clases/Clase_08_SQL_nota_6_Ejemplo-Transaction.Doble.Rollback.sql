begin tran
select * from EMPRESA;
insert into EMPRESA values 
('1', 'color', 'direccion', 'xxx'),
('2', 'color', 'direccion', 'xxx'),
('3', 'color', 'direccion', 'xxx'),
('4', 'color', 'direccion', 'xxx');
select * from EMPRESA;
rollback tran
select * from EMPRESA;
-- rollback tran
