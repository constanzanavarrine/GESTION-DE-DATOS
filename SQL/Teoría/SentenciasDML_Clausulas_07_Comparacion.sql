--Ejemplo 1

select *
from compañia
where desc_empr like 'Local%';

-- ; sirve para separar sentencias SQL en un mismo script.

--Ejemplo 2
select nom, fec_egr
from empleado
where fec_egr is not null;

--Ejemplo 3
select *
from locales
where cod_local between 1 and 10;

--Ejemplo 4
select nom,tipo_empl,tel
from empleado
where tipo_empl in ('ADM', 'VEND');
-- aca la columna tipo_empl debe ser igual a ADM o VEND