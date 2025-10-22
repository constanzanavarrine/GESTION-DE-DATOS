--  begin transaction

SELECT TOP (1000) [CUIL]
      ,[RAZON_SOCIAL]
      ,[DIRECCION]
      ,[TELEFONO]
  FROM [borrar].[dbo].[EMPRESA]

insert into EMPRESA values 
('1', 'color', 'direccion', 'xxx'),
('2', 'color', 'direccion', 'xxx'),
('3', 'color', 'direccion', 'xxx'),
('4', 'color', 'direccion', 'xxx');

SELECT * FROM [borrar].[dbo].[EMPRESA];
rollback transaction
SELECT * FROM [borrar].[dbo].[EMPRESA];
