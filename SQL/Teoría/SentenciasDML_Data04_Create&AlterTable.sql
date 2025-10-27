GENÉRICO: CREACIÓN DE TABLA Y ALTERACIÓN DE OTRA
──────────────────────────────────────────────

-- 1) Crear una nueva tabla
CREATE TABLE NombreTabla (
    NombreColumna1  TipoDeDato  [NULL | NOT NULL],
    NombreColumna2  TipoDeDato  [NULL | NOT NULL],
    ...
    CONSTRAINT pk_NombreTabla PRIMARY KEY (NombreColumna1)
);

-- 2) Agregar nuevas columnas a una tabla existente
ALTER TABLE NombreTablaExistente
ADD COLUMN NombreColumnaNueva1 TipoDeDato [NULL | NOT NULL],
ADD COLUMN NombreColumnaNueva2 TipoDeDato [NULL | NOT NULL];

-- 3) Agregar restricciones (constraints)
ALTER TABLE NombreTablaExistente
ADD CONSTRAINT fk_NombreConstraint
    FOREIGN KEY (ColumnaFK)
    REFERENCES TablaReferenciada(ColumnaPK),
ADD CONSTRAINT ck_NombreConstraint
    CHECK (condición_lógica),
ADD CONSTRAINT uq_NombreConstraint
    UNIQUE (Columna1, Columna2);






MINI GUIA DE TIPOS DE constraints
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
| Tipo de constraint | Qué hace                            | Ejemplo                                            |
| ------------------ | ----------------------------------- | -------------------------------------------------- |
| **PRIMARY KEY**    | Identifica de forma única cada fila | `PRIMARY KEY (id)`                                 |
| **FOREIGN KEY**    | Vincula con otra tabla              | `FOREIGN KEY (id_cliente) REFERENCES CLIENTES(id)` |
| **UNIQUE**         | Evita duplicados                    | `UNIQUE (dni)`                                     |
| **CHECK**          | Impone una condición lógica         | `CHECK (edad >= 18)`                               |
| **DEFAULT**        | Asigna un valor por defecto         | `DEFAULT GETDATE()`                                |
| **NOT NULL**       | No permite valores nulos            | `nombre VARCHAR(50) NOT NULL`                      |