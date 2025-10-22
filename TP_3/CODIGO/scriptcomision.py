# -*- coding: utf-8 -*-
# Actualiza COMISION.csv calculando:
# - CANTIDAD_ALUMNOS (desde ALUMNO_COMISION.csv)
# - CANTIDAD_DOCENTES (desde DOCENTE_COMISION.csv; cuenta filas o docentes únicos si hay ID_DOCENTE)
# - FECHA_INICIO_ESPERADA = max(FECHA_ALTA alumnos) + (3..14 días)
# - FECHA_FINALIZACION_ESPERADA = FECHA_INICIO_ESPERADA + (20..30 semanas)
# - FECHA_INICIO_REAL / FECHA_FINALIZACION_REAL = mismas que esperadas
# Si no hay fechas (no hay alumnos), preserva las fechas originales del COMISION.csv.

import pandas as pd
import glob, random
from datetime import datetime, timedelta

random.seed(2025)

# ---------- Helpers ----------
def parse_dt(s):
    if pd.isna(s): return None
    s = str(s).strip()
    if not s or s.upper() == "NULL": return None
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

def find_exact(name, alt_pattern):
    """Intenta primero el nombre exacto, si no, un comodín."""
    hits = glob.glob(name)
    if hits: return hits[0]
    hits = glob.glob(alt_pattern)
    return hits[0] if hits else None

# ---------- Entradas obligatorias ----------
COM_PATH = find_exact("COMISION.csv", "*COMISION*.csv")
ALU_PATH = find_exact("ALUMNO_COMISION.csv", "*ALUMNO_COMISION*.csv")
DOC_PATH = find_exact("DOCENTE_COMISION.csv", "*DOCENTE_COMISION*.csv")

if not COM_PATH or not ALU_PATH or not DOC_PATH:
    raise FileNotFoundError("No encontré alguno de los archivos requeridos: COMISION.csv / ALUMNO_COMISION.csv / DOCENTE_COMISION.csv")

# Leer CSV
com = pd.read_csv(COM_PATH, dtype=str)
alu = pd.read_csv(ALU_PATH, dtype=str)
doc = pd.read_csv(DOC_PATH, dtype=str)

# Normalizar headers
com.columns = [c.strip() for c in com.columns]
alu.columns = [c.strip() for c in alu.columns]
doc.columns = [c.strip() for c in doc.columns]

# Validaciones mínimas
for req in ["ID_COMISION","ID_FORMACION","NOMBRE"]:
    if req not in com.columns:
        raise ValueError(f"COMISION.csv no tiene la columna obligatoria {req}")

for req in ["ID_COMISION","ID_ALUMNO"]:
    if req not in alu.columns:
        raise ValueError(f"ALUMNO_COMISION.csv no tiene la columna obligatoria {req}")

if "ID_COMISION" not in doc.columns:
    raise ValueError("DOCENTE_COMISION.csv no tiene la columna obligatoria ID_COMISION")

# ---------- CANTIDADES ----------
# alumnos por comisión
alu_counts = alu.groupby("ID_COMISION").size().rename("__CNT_ALUMNOS")

# docentes por comisión (con tu DDL contamos filas; si existiera ID_DOCENTE, podríamos contar únicos)
if "ID_DOCENTE" in doc.columns:
    doc_counts = doc.groupby("ID_COMISION")["ID_DOCENTE"].nunique().rename("__CNT_DOCENTES")
else:
    doc_counts = doc.groupby("ID_COMISION").size().rename("__CNT_DOCENTES")

out = com.copy()

# Hacemos merges con nombres auxiliares para NO chocar con columnas existentes
out = out.merge(alu_counts, how="left", left_on="ID_COMISION", right_index=True)
out = out.merge(doc_counts, how="left", left_on="ID_COMISION", right_index=True)

# Si no había conteo (NaN), poner 0
out["__CNT_ALUMNOS"]  = out["__CNT_ALUMNOS"].fillna(0).astype(int)
out["__CNT_DOCENTES"] = out["__CNT_DOCENTES"].fillna(0).astype(int)

# Sobrescribimos columnas finales y luego borramos auxiliares
out["CANTIDAD_ALUMNOS"]  = out["__CNT_ALUMNOS"]
out["CANTIDAD_DOCENTES"] = out["__CNT_DOCENTES"]
out = out.drop(columns=["__CNT_ALUMNOS","__CNT_DOCENTES"], errors="ignore")

# ---------- FECHAS ----------
# Max FECHA_ALTA por comisión desde ALUMNO_COMISION (DOCENTE_COMISION no trae FECHA_ALTA en tu DDL)
if "FECHA_ALTA" in alu.columns:
    alu_dates = alu.copy()
    alu_dates["FECHA_ALTA_DT"] = alu_dates["FECHA_ALTA"].apply(parse_dt)
    alu_dates = alu_dates.dropna(subset=["FECHA_ALTA_DT"])
    max_alta_by_comm = alu_dates.groupby("ID_COMISION")["FECHA_ALTA_DT"].max()
else:
    max_alta_by_comm = pd.Series(dtype="datetime64[ns]")

nuevos_ini = []
nuevos_fin = []

for _, r in out.iterrows():
    comm_id = str(r["ID_COMISION"])
    base_dt = max_alta_by_comm.get(comm_id, pd.NaT)

    if pd.isna(base_dt):
        # No hay fechas de alta en alumnos para esta comisión -> preservar lo que ya tenga
        ini_esp_old = parse_dt(r.get("FECHA_INICIO_ESPERADA"))
        fin_esp_old = parse_dt(r.get("FECHA_FINALIZACION_ESPERADA"))

        if ini_esp_old and fin_esp_old:
            ini_esp = ini_esp_old
            fin_esp = fin_esp_old
        elif ini_esp_old and not fin_esp_old:
            fin_esp = ini_esp_old + timedelta(days=random.randint(20,30)*7)
            ini_esp = ini_esp_old
        else:
            # si no hay nada, las dejamos vacías
            ini_esp = None
            fin_esp = None
    else:
        # FECHA_INICIO_ESPERADA = (último en registrarse) + 3..14 días
        ini_esp = base_dt + timedelta(days=random.randint(3,14),
                                      seconds=random.randint(0, 3600))
        # FECHA_FINALIZACION_ESPERADA = inicio + 20..30 semanas
        fin_esp = ini_esp + timedelta(days=random.randint(20,30)*7,
                                      seconds=random.randint(0, 3600))
        if fin_esp <= ini_esp:
            fin_esp = ini_esp + timedelta(days=140)

    nuevos_ini.append(ini_esp)
    nuevos_fin.append(fin_esp)

def fmt_or_empty(x):
    return fmt_ms(x) if isinstance(x, datetime) else ""

out["FECHA_INICIO_ESPERADA"]       = [fmt_or_empty(x) for x in nuevos_ini]
out["FECHA_FINALIZACION_ESPERADA"] = [fmt_or_empty(x) for x in nuevos_fin]

# FECHAS REALES = mismas que esperadas (si están vacías, quedan vacías)
out["FECHA_INICIO_REAL"]       = out["FECHA_INICIO_ESPERADA"]
out["FECHA_FINALIZACION_REAL"] = out["FECHA_FINALIZACION_ESPERADA"]

# Orden de columnas tal cual pediste
cols = ["ID_COMISION","ID_FORMACION","NOMBRE",
        "FECHA_INICIO_ESPERADA","FECHA_FINALIZACION_ESPERADA",
        "FECHA_INICIO_REAL","FECHA_FINALIZACION_REAL",
        "CANTIDAD_ALUMNOS","CANTIDAD_DOCENTES"]
out = out[cols]

# Guardar
out.to_csv("COMISION_ACTUALIZADO.csv", index=False, encoding="utf-8")
print("✅ Listo: COMISION_ACTUALIZADO.csv")
