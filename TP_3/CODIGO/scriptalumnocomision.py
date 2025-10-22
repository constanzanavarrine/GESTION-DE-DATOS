# -*- coding: utf-8 -*-
# Modifica solo FECHA_ALTA y FECHA_BAJA en ALUMNO_COMISION.csv
# Pasos:
#  - Ordena por ID_COMISION asc.
#  - En cada comisión, toma el alumno con FECHA_ALTA más grande y copia
#    su FECHA_ALTA y FECHA_BAJA a todos los alumnos de esa comisión.

import pandas as pd
from datetime import datetime
import glob
import os

IN_FILE  = "ALUMNO_COMISION.csv"
OUT_FILE = "ALUMNO_COMISION_ACTUALIZADO.csv"

def find_exact(name, alt_pattern):
    hits = glob.glob(name)
    if hits: return hits[0]
    hits = glob.glob(alt_pattern)
    return hits[0] if hits else None

def parse_dt(s):
    if pd.isna(s): return None
    s = str(s).strip()
    if not s or s.upper() == "NULL":
        return None
    for fmt in ("%Y-%m-%d %H:%M:%S.%f",
                "%Y-%m-%d %H:%M:%S",
                "%Y-%m-%d",
                "%d/%m/%Y %H:%M:%S",
                "%d/%m/%Y"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            continue
    return None

def fmt_ms(dt):
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

# --------- Cargar ----------
src = find_exact(IN_FILE, "*ALUMNO_COMISION*.csv")
if not src:
    raise FileNotFoundError("No se encontró ALUMNO_COMISION.csv (ni *ALUMNO_COMISION*.csv) en la carpeta actual.")

df = pd.read_csv(src, dtype=str)
df.columns = [c.strip() for c in df.columns]

# Validar columnas requeridas
requeridas = ["ID_ALUMNO_COMISION","ID_ALUMNO","ID_COMISION","ESTADO","NOTA",
              "CERTIFICADO_FECHA_EXPEDICION","ID_CERTIFICADO","FECHA_ALTA","FECHA_BAJA"]
faltan = [c for c in requeridas if c not in df.columns]
if faltan:
    raise ValueError(f"Faltan columnas en ALUMNO_COMISION.csv: {faltan}")

# --------- Ordenar por ID_COMISION asc ----------
# (No tocamos el header, solo ordenamos las filas)
df = df.sort_values(by=["ID_COMISION", "ID_ALUMNO_COMISION"], ascending=[True, True], kind="mergesort").reset_index(drop=True)

# --------- Procesar por comisión ----------
# Convertimos fechas a dt para calcular máximo; mantenemos copia original para formatear al final
df["_FECHA_ALTA_DT"] = df["FECHA_ALTA"].apply(parse_dt)
df["_FECHA_BAJA_DT"] = df["FECHA_BAJA"].apply(parse_dt)

def aplicar_por_comision(grp: pd.DataFrame) -> pd.DataFrame:
    # Encontrar FECHA_ALTA más grande (ignorando vacíos)
    if grp["_FECHA_ALTA_DT"].notna().any():
        idx_rep = grp["_FECHA_ALTA_DT"].idxmax()
        rep_alta_dt = grp.loc[idx_rep, "_FECHA_ALTA_DT"]
        rep_baja_dt = grp.loc[idx_rep, "_FECHA_BAJA_DT"]  # puede ser None

        # Formateos (si hay fecha, formateo; si no, vacío)
        rep_alta_str = fmt_ms(rep_alta_dt) if pd.notna(rep_alta_dt) else ""
        rep_baja_str = fmt_ms(rep_baja_dt) if pd.notna(rep_baja_dt) else ""

        grp["FECHA_ALTA"] = rep_alta_str
        grp["FECHA_BAJA"] = rep_baja_str
    # Si todas las FECHA_ALTA están vacías en la comisión, no tocamos nada
    return grp

df = df.groupby("ID_COMISION", group_keys=False).apply(aplicar_por_comision)

# Limpiar columnas auxiliares
df = df.drop(columns=["_FECHA_ALTA_DT","_FECHA_BAJA_DT"], errors="ignore")

# --------- Guardar ----------
df.to_csv(OUT_FILE, index=False, encoding="utf-8")
print(f"✅ Hecho: {os.path.abspath(OUT_FILE)}")
