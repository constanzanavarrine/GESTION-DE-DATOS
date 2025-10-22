SELECT TOP (5) * FROM [gd_teoria_c_d].[dbo].[PERSONA] ORDER BY NOMBRE asc;
SELECT TOP (5) * FROM [gd_teoria_c_d].[dbo].[PERSONA] ORDER BY CODIGOPOSTAL, NOMBRE asc;
SELECT TOP (5) * FROM [gd_teoria_c_d].[dbo].[PERSONA] ORDER BY 5 asc;

SELECT TOP (5) [IDPERSONA]
      ,[NOMBRE]
      ,[CODIGOPOSTAL]
      ,[NRODOC]
      ,[FECHA_DE_NACIMIENTO]
      ,[FECHA_DE_ALTA]
      ,[FECHA_DE_BAJA]
      ,[IDMOTIVO_DE_BAJA]
      ,[IDPAIS]
      ,[APELLIDO]
      ,[ACTIVO]
  FROM [gd_teoria_c_d].[dbo].[PERSONA]
  ORDER BY NOMBRE asc
