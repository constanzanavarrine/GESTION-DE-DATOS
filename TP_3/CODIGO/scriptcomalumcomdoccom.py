import csv
import os
import glob
import random
from datetime import datetime, timedelta

random.seed(123)

# --------------------------
# Archivos base (se aceptan comodines)
# --------------------------
ALUMNOS_CAND   = ["alumnos.csv", "*ALUMNO*.csv", "*Alumnos*.csv"]
DOCENTES_CAND  = ["docentes.csv", "*DOCENTE*.csv"]
FORMACION_CAND = ["formacion.csv", "*FORMACION*.csv"]
ROL_CAND       = ["rol.csv", "*ROL*.csv"]

# Salidas
COMISION_OUT          = "comision.csv"
DOCENTE_COMISION_OUT  = "docente_comision.csv"
ALUMNO_COMISION_OUT   = "alumno_comision.csv"

# --------------------------
# Parámetros del proyecto
# --------------------------
WINDOW_START = datetime(2023, 1, 1, 0, 0, 0, 0)
WINDOW_END   = datetime(2025, 5, 30, 23, 59, 59, 999000)
TODAY_REF    = datetime(2025, 5, 30, 23, 59, 59, 0)

N_COMISIONES = 100
ALUMNOS_MIN_POR_COMISION = 20
ALUMNOS_MAX_POR_COMISION = 80
DOCENTES_MIN_POR_COMISION = 1
DOCENTES_MAX_POR_COMISION = 5
LETRAS_SECCION = [chr(ord('A') + i) for i in range(8)]  # A..H

# --------------------------
# Helpers
# --------------------------
def find_first(patterns):
    for p in patterns:
        if "*" in p:
            hits = glob.glob(p)
            if hits:
                return sorted(hits)[0]
        else:
            if os.path.exists(p):
                return p
    return None

def parse_dt_any(s: str):
    if not s:
        return None
    s = s.strip()
    if not s:
        return None
    for fmt in ("%Y-%m-%d %H:%M:%S.%f","%Y-%m-%d %H:%M:%S","%Y-%m-%d","%d/%m/%Y"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            pass
    return None

def fmt_ms(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]  # DATETIME con milisegundos

def month_weight(m):
    # picos: Ene-Feb y Jun-Jul
    return 3 if m in (1,2,6,7) else 1

def random_time_of_day():
    return timedelta(
        hours=random.randint(8, 21),
        minutes=random.randint(0, 59),
        seconds=random.randint(0, 59),
        milliseconds=random.randint(0, 999)
    )

def distribute_counts(total, months_weights):
    months, weights = zip(*months_weights)
    wsum = sum(weights)
    raw = [total * w / wsum for w in weights]
    base = [int(x) for x in raw]
    rem  = total - sum(base)
    residuals = sorted(
        list(enumerate([r - b for r, b in zip(raw, base)])),
        key=lambda x: x[1], reverse=True
    )
    for i in range(rem):
        base[residuals[i][0]] += 1
    return dict(zip(months, base))

def month_iter(start: datetime, end: datetime):
    y, m = start.year, start.month
    cur = datetime(y, m, 1)
    while cur <= end:
        ny, nm = (cur.year + 1, 1) if cur.month == 12 else (cur.year, cur.month + 1)
        next_m = datetime(ny, nm, 1)
        start_eff = max(cur, start)
        end_eff = min(next_m - timedelta(milliseconds=1), end)
        if start_eff <= end_eff:
            yield (cur.year, cur.month, start_eff, end_eff)
        cur = next_m

def gen_incremental_dates(n, start, end):
    """n fechas entre [start,end] con más densidad en Ene-Feb y Jun-Jul, estrictamente crecientes."""
    months_info = list(month_iter(start, end))  # (y, m, start_m, end_m)
    months_weights = [(((y, m), month_weight(m))) for (y, m, _, _) in months_info]
    counts = distribute_counts(n, months_weights)

    tentative = []
    for (y, m, start_m, end_m) in months_info:
        cnt = counts.get((y, m), 0)
        if cnt <= 0:
            continue
        span_days = max(1, (end_m.date() - start_m.date()).days)
        for i in range(cnt):
            day_offset = int((i + 1) * (span_days / (cnt + 1)))
            base_day = start_m + timedelta(days=day_offset)
            dt = base_day.replace(hour=0, minute=0, second=0, microsecond=0) + random_time_of_day()
            dt = max(start_m, min(dt, end_m))
            tentative.append(dt)

    tentative.sort()
    # Estrictamente crecientes (1 ms)
    for i in range(1, len(tentative)):
        if tentative[i] <= tentative[i-1]:
            tentative[i] = tentative[i-1] + timedelta(milliseconds=1)
    return tentative[:n]

# --------------------------
# Lectura insumos
# --------------------------
alumnos_path   = find_first(ALUMNOS_CAND)   or "alumnos.csv"
docentes_path  = find_first(DOCENTES_CAND)  or "docentes.csv"
formacion_path = find_first(FORMACION_CAND) or "formacion.csv"
rol_path       = find_first(ROL_CAND)       or "rol.csv"

def read_alumnos(path):
    L = []
    with open(path, newline="", encoding="utf-8") as f:
        rdr = csv.DictReader(f)
        for r in rdr:
            if not r.get("ID_ALUMNO"):
                continue
            L.append({"ID_ALUMNO": int(r["ID_ALUMNO"]),
                      "FECHA_ALTA": parse_dt_any(r.get("FECHA_ALTA",""))})
    if not L:
        raise RuntimeError("alumnos.csv sin filas válidas (ID_ALUMNO, FECHA_ALTA).")
    return L

def read_docentes(path):
    L = []
    with open(path, newline="", encoding="utf-8") as f:
        rdr = csv.DictReader(f)
        for r in rdr:
            if not r.get("ID_DOCENTE"):
                continue
            L.append({"ID_DOCENTE": int(r["ID_DOCENTE"]),
                      "FECHA_ALTA": parse_dt_any(r.get("FECHA_ALTA",""))})
    if not L:
        raise RuntimeError("docentes.csv sin filas válidas (ID_DOCENTE).")
    return L

def read_formaciones(path):
    L = []
    with open(path, newline="", encoding="utf-8") as f:
        rdr = csv.DictReader(f)
        for r in rdr:
            R = {k.strip().upper(): (v or "").strip() for k,v in r.items()}
            if not R.get("ID_FORMACION"):
                continue
            semanas = None
            if R.get("CANTIDAD_SEMANAS"):
                try: semanas = int(float(R["CANTIDAD_SEMANAS"]))
                except: pass
            L.append({
                "ID_FORMACION": int(R["ID_FORMACION"]),
                "NOMBRE": R.get("NOMBRE",""),
                "CANTIDAD_SEMANAS": semanas,
                "FECHA_ALTA": parse_dt_any(R.get("FECHA_ALTA",""))
            })
    if not L:
        raise RuntimeError("formacion.csv sin filas válidas (ID_FORMACION, NOMBRE).")
    return L

def read_roles(path):
    L=[]
    if not os.path.exists(path):
        return [
            {"ID_ROL":1,"NOMBRE":"Profesor principal"},
            {"ID_ROL":2,"NOMBRE":"Tutor"},
            {"ID_ROL":3,"NOMBRE":"Asistente"},
            {"ID_ROL":4,"NOMBRE":"Jefe de catedra"},
            {"ID_ROL":5,"NOMBRE":"Profesor auxiliar"},
        ]
    with open(path, newline="", encoding="utf-8") as f:
        rdr = csv.DictReader(f)
        for r in rdr:
            if r.get("ID_ROL"):
                L.append({"ID_ROL": int(r["ID_ROL"]), "NOMBRE": r.get("NOMBRE","")})
    return L

alumnos  = read_alumnos(alumnos_path)
docentes = read_docentes(docentes_path)
forms    = read_formaciones(formacion_path)
roles    = read_roles(rol_path)

alumno_ids  = [a["ID_ALUMNO"] for a in alumnos]
docente_ids = [d["ID_DOCENTE"] for d in docentes]
rol_ids     = [r["ID_ROL"] for r in roles]

alumno_by_id = {a["ID_ALUMNO"]: a for a in alumnos}
form_by_id   = {f["ID_FORMACION"]: f for f in forms}

# --------------------------
# 1) COMISION (100) con fechas incrementales
# --------------------------
# 1.a) Generar base incremental de FECHA_INICIO_ESPERADA
base_inicios = gen_incremental_dates(N_COMISIONES, WINDOW_START, WINDOW_END - timedelta(days=21))

comisiones = []
last_start_exp = None
last_end_exp   = None
last_start_real= None
last_end_real  = None

for i in range(1, N_COMISIONES+1):
    id_form = random.choice(list(form_by_id.keys()))
    f = form_by_id[id_form]

    # Ajustar inicio esperado para respetar: base incremental, alta de la formación y monotonicidad
    candidate = base_inicios[i-1]
    min_start = max(WINDOW_START, f.get("FECHA_ALTA") or WINDOW_START, candidate)
    if last_start_exp:
        min_start = max(min_start, last_start_exp + timedelta(milliseconds=1))
    start_exp = min_start

    # Duración esperada
    semanas = f.get("CANTIDAD_SEMANAS") if f.get("CANTIDAD_SEMANAS") else random.randint(12, 24)
    end_exp_candidate = start_exp + timedelta(days=7*semanas)
    if last_end_exp and end_exp_candidate <= last_end_exp:
        end_exp = last_end_exp + timedelta(milliseconds=1)
    else:
        end_exp = end_exp_candidate
    end_exp = min(end_exp, WINDOW_END)

    # Fechas reales (si corresponde), asegurando no-decreciente respecto a las reales previas
    started_expected  = start_exp <= TODAY_REF
    finished_expected = end_exp   <= TODAY_REF

    if started_expected:
        start_real = start_exp + timedelta(days=random.randint(-5, 5))
        start_real = max(start_real, start_exp)
        if last_start_real and start_real <= last_start_real:
            start_real = last_start_real + timedelta(milliseconds=1)
    else:
        start_real = None

    if finished_expected:
        base_end_real = end_exp + timedelta(days=random.randint(-7, 7))
        min_end_real  = (start_real or start_exp) + timedelta(days=7)
        end_real = max(base_end_real, min_end_real)
        if last_end_real and end_real <= last_end_real:
            end_real = last_end_real + timedelta(milliseconds=1)
        end_real = min(end_real, WINDOW_END)
    else:
        end_real = None

    last_start_exp = start_exp
    last_end_exp   = end_exp
    if start_real:
        last_start_real = start_real
    if end_real:
        last_end_real = end_real

    # Cantidades
    cant_alumnos  = random.randint(ALUMNOS_MIN_POR_COMISION, ALUMNOS_MAX_POR_COMISION)
    cant_docentes = random.randint(DOCENTES_MIN_POR_COMISION, DOCENTES_MAX_POR_COMISION)

    # Nombre = letra A..H
    nombre = LETRAS_SECCION[(i-1) % len(LETRAS_SECCION)]

    comisiones.append({
        "ID_COMISION": i,
        "ID_FORMACION": id_form,
        "NOMBRE": nombre,
        "FECHA_INICIO_ESPERADA": start_exp,
        "FECHA_FINALIZACION_ESPERADA": end_exp,
        "FECHA_INICIO_REAL": start_real,
        "FECHA_FINALIZACION_REAL": end_real,
        "CANTIDAD_ALUMNOS": cant_alumnos,
        "CANTIDAD_DOCENTES": cant_docentes
    })

# --------------------------
# 2) DOCENTE_COMISION (≥100)
# --------------------------
dc_rows = []
id_dc = 1
for c in comisiones:
    n_doc = c["CANTIDAD_DOCENTES"]
    docentes_elegidos = set()
    while len(docentes_elegidos) < n_doc:
        docentes_elegidos.add(random.choice(docente_ids))
    roles_pool = rol_ids[:]
    random.shuffle(roles_pool)
    roles_elegidos = []
    for k in range(n_doc):
        roles_elegidos.append(roles_pool.pop() if roles_pool else random.choice(rol_ids))
    for did, rid in zip(docentes_elegidos, roles_elegidos):
        dc_rows.append({
            "ID_DOCENTE_COMISION": id_dc,
            "ID_DOCENTE": did,
            "ID_ROL": rid,
            "ID_COMISION": c["ID_COMISION"]
        })
        id_dc += 1

# Ajustar CANTIDAD_DOCENTES exacta según lo generado
from collections import Counter
doc_count_by_comm = Counter([r["ID_COMISION"] for r in dc_rows])
for c in comisiones:
    c["CANTIDAD_DOCENTES"] = doc_count_by_comm.get(c["ID_COMISION"], 0)

# --------------------------
# 3) ALUMNO_COMISION (suma de cupos) con FECHA_ALTA estrictamente incremental
# --------------------------
ac_rows = []
last_ac_fecha_alta = WINDOW_START
id_ac = 1
id_cert = 1

for c in comisiones:
    id_com = c["ID_COMISION"]
    start_for_join = c["FECHA_INICIO_REAL"] or c["FECHA_INICIO_ESPERADA"]
    end_for_join   = c["FECHA_FINALIZACION_REAL"] or c["FECHA_FINALIZACION_ESPERADA"]

    cupo = c["CANTIDAD_ALUMNOS"]
    elegidos = set()
    while len(elegidos) < cupo:
        elegidos.add(random.choice(alumno_ids))

    for aid in elegidos:
        alumno_alta = alumno_by_id[aid]["FECHA_ALTA"] or WINDOW_START
        start_min = max(alumno_alta, start_for_join, last_ac_fecha_alta + timedelta(milliseconds=1))
        start_max = min(end_for_join, WINDOW_END)
        if start_min > start_max:
            # corrimiento al final de ventana si el alumno es muy nuevo
            start_min = min(start_min, WINDOW_END - timedelta(days=1))
            start_max = max(start_min + timedelta(milliseconds=1), WINDOW_END)
        # muestra en rango con picos (Ene-Feb / Jun-Jul)
        # para mantener incrementalidad estricta:
        fecha_alta = start_min + timedelta(milliseconds=random.randint(0, 999))
        if fecha_alta <= last_ac_fecha_alta:
            fecha_alta = last_ac_fecha_alta + timedelta(milliseconds=1)
        last_ac_fecha_alta = fecha_alta

        # Estado / nota / certificado
        started  = start_for_join <= TODAY_REF
        finished = (c["FECHA_FINALIZACION_REAL"] or c["FECHA_FINALIZACION_ESPERADA"]) <= TODAY_REF

        if not started:
            estado = "en curso"
        else:
            if finished:
                estado = "aprobado" if random.random() < 0.7 else "desaprobado"
            else:
                p = random.random()
                estado = "en curso" if p < 0.7 else ("aprobado" if p < 0.85 else "desaprobado")

        if estado == "aprobado":
            nota = round(random.uniform(6.00, 10.00), 2)
            cert_base = c["FECHA_FINALIZACION_REAL"] or c["FECHA_FINALIZACION_ESPERADA"]
            cert_dt = min(cert_base + timedelta(days=random.randint(1, 20)), WINDOW_END)
            id_certificado = id_cert
            id_cert += 1
            fecha_baja = cert_dt
        elif estado == "desaprobado":
            nota = round(random.uniform(1.00, 5.99), 2)
            cert_dt = None
            id_certificado = None
            fecha_baja = min(end_for_join + timedelta(days=random.randint(0, 10)), WINDOW_END)
        else:
            nota = None
            cert_dt = None
            id_certificado = None
            fecha_baja = None

        ac_rows.append({
            "ID_ALUMNO_COMISION": id_ac,
            "ID_ALUMNO": aid,
            "ID_COMISION": id_com,
            "ESTADO": estado,
            "NOTA": f"{nota:.2f}" if nota is not None else "",
            "CERTIFICADO_FECHA_EXPEDICION": fmt_ms(cert_dt) if cert_dt else "",
            "ID_CERTIFICADO": id_certificado if id_certificado else "",
            "FECHA_ALTA": fmt_ms(fecha_alta),
            "FECHA_BAJA": fmt_ms(fecha_baja) if fecha_baja else ""
        })
        id_ac += 1

# --------------------------
# Exportar CSVs
# --------------------------
with open(COMISION_OUT, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=[
        "ID_COMISION","ID_FORMACION","NOMBRE",
        "FECHA_INICIO_ESPERADA","FECHA_FINALIZACION_ESPERADA",
        "FECHA_INICIO_REAL","FECHA_FINALIZACION_REAL",
        "CANTIDAD_ALUMNOS","CANTIDAD_DOCENTES"
    ])
    w.writeheader()
    for c in comisiones:
        w.writerow({
            "ID_COMISION": c["ID_COMISION"],
            "ID_FORMACION": c["ID_FORMACION"],
            "NOMBRE": c["NOMBRE"],  # "A".."H"
            "FECHA_INICIO_ESPERADA": fmt_ms(c["FECHA_INICIO_ESPERADA"]),
            "FECHA_FINALIZACION_ESPERADA": fmt_ms(c["FECHA_FINALIZACION_ESPERADA"]),
            "FECHA_INICIO_REAL": fmt_ms(c["FECHA_INICIO_REAL"]) if c["FECHA_INICIO_REAL"] else "",
            "FECHA_FINALIZACION_REAL": fmt_ms(c["FECHA_FINALIZACION_REAL"]) if c["FECHA_FINALIZACION_REAL"] else "",
            "CANTIDAD_ALUMNOS": c["CANTIDAD_ALUMNOS"],
            "CANTIDAD_DOCENTES": c["CANTIDAD_DOCENTES"]
        })

with open(DOCENTE_COMISION_OUT, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["ID_DOCENTE_COMISION","ID_DOCENTE","ID_ROL","ID_COMISION"])
    w.writeheader()
    for i, row in enumerate(dc_rows := [
        # rebuild list to ensure IDs consecutivos
        {"ID_DOCENTE_COMISION": idx+1, "ID_DOCENTE": r["ID_DOCENTE"], "ID_ROL": r["ID_ROL"], "ID_COMISION": r["ID_COMISION"]}
        for idx, r in enumerate(dc_rows)
    ]):
        w.writerow(row)

with open(ALUMNO_COMISION_OUT, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=[
        "ID_ALUMNO_COMISION","ID_ALUMNO","ID_COMISION","ESTADO","NOTA",
        "CERTIFICADO_FECHA_EXPEDICION","ID_CERTIFICADO","FECHA_ALTA","FECHA_BAJA"
    ])
    w.writeheader()
    for i, row in enumerate(ac_rows):
        row["ID_ALUMNO_COMISION"] = i + 1
        w.writerow(row)

print(f"✅ Generados:\n - {COMISION_OUT} (100 filas)\n - {DOCENTE_COMISION_OUT} ({len(dc_rows)} filas)\n - {ALUMNO_COMISION_OUT} ({len(ac_rows)} filas)")
