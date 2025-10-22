# -*- coding: utf-8 -*-
# Facturas (1000), Detalles (1–3/Factura), Pagos (1/Factura), Historial de Precios.
# Emisiones distribuidas por días (<= MAX_POR_DIA) con picos Nov-Dic / Jun-Jul,
# todo estrictamente incremental y consistente con ALUMNO.FECHA_ALTA.

import csv, os, glob, random
from datetime import datetime, timedelta

random.seed(12345)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# ---------- Config ----------
N_FACTURAS   = 1000
MAX_POR_DIA  = 3            # máximo de facturas por día (cambiá si querés 3, 4, etc.)
PICO_MESES   = { (2023,11), (2023,12), (2024,6), (2024,7), (2024,11), (2024,12) }

# ---------- Utils ----------
def ff(*patterns):
    pats=[]
    for p in patterns:
        pats += [p, p.lower(), p.upper()]
    for p in pats:
        hits = glob.glob(os.path.join(BASE_DIR, p))
        if hits: return sorted(hits)[0]
    return None

def parse_dt(s):
    if not s: return None
    s = s.strip()
    for fmt in ("%Y-%m-%d %H:%M:%S.%f","%Y-%m-%d %H:%M:%S","%Y-%m-%d","%d/%m/%Y"):
        try: return datetime.strptime(s, fmt)
        except ValueError: pass
    return None

def fmt_ms(dt): return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

def to_int_str(x):
    if x is None or x=="": return "0"
    if isinstance(x,(int,float)): return str(int(round(x)))
    try: return str(int(round(float(str(x).replace(",", ".")))))
    except: return "0"

def rand_tod():
    return timedelta(hours=random.randint(8,21),
                     minutes=random.randint(0,59),
                     seconds=random.randint(0,59),
                     microseconds=random.randint(0,999)*1000)

def month_weight(year, month):
    # picos reales en 2023-2024, resto peso 1; 2025 un poco menor (2 en Ene-Feb)
    if (year, month) in PICO_MESES: return 6
    if year == 2025 and month in (1,2): return 2
    return 1

def gen_emisiones_por_dia(n, start_dt, end_dt, max_por_dia=5):
    """Devuelve n timestamps entre start_dt y end_dt con:
       - límite de 'max_por_dia' por fecha (día)
       - mayor peso en meses pico
       - estrictamente crecientes
    """
    # 1) lista de días
    days = []
    d = start_dt.date()
    end_d = end_dt.date()
    while d <= end_d:
        days.append(d)
        d += timedelta(days=1)

    # 2) pesos por mes
    weights = [month_weight(day.year, day.month) for day in days]
    W = sum(weights) if sum(weights) > 0 else 1

    # 3) cuántas facturas por día (redondeo + tope)
    raw = [n * (w / W) for w in weights]
    base = [min(max_por_dia, int(x)) for x in raw]
    usado = sum(base)

    # residuales por parte fraccionaria y capacidad restante
    residuals = sorted(
        list(enumerate([(raw[i]-int(raw[i])) for i in range(len(raw))])),
        key=lambda x: x[1], reverse=True
    )
    i = 0
    while usado < n and i < len(residuals):
        idx = residuals[i][0]
        if base[idx] < max_por_dia:
            base[idx] += 1
            usado += 1
        i += 1
    # si aún falta, relleno respetando tope
    j = 0
    while usado < n and j < len(base):
        if base[j] < max_por_dia:
            base[j] += 1; usado += 1
        j += 1
    # si nos pasamos (raro), saco del final
    k = len(base)-1
    while usado > n and k >= 0:
        if base[k] > 0:
            base[k] -= 1; usado -= 1
        k -= 1

    # 4) timestamps dentro de cada día
    pts=[]
    for day, cnt in zip(days, base):
        for _ in range(cnt):
            dt = datetime(day.year, day.month, day.day) + rand_tod()
            # clamp al rango
            if dt < start_dt: dt = start_dt + rand_tod()
            if dt > end_dt:   dt = end_dt - timedelta(seconds=1)
            pts.append(dt)

    # 5) orden + asegurar estrictamente crecientes
    pts.sort()
    for i in range(1, len(pts)):
        if pts[i] <= pts[i-1]:
            pts[i] = pts[i-1] + timedelta(milliseconds=2)
    return pts[:n]

def bump_after(dt, last_dt, ms=2):
    return (last_dt + timedelta(milliseconds=ms)) if (last_dt and dt <= last_dt) else dt

def safe_base_series(n, start_dt, end_dt, max_por_dia, prefer_days=True):
    """
    Genera exactamente n timestamps entre start_dt y end_dt.
    1) Intenta con gen_emisiones_por_dia (tope por día).
    2) Si no alcanza, completa el faltante espaciando linealmente (fallback).
    """
    base = gen_emisiones_por_dia(n, start_dt, end_dt, max_por_dia=max_por_dia) if prefer_days else []
    if len(base) < n:
        falta = n - len(base)
        span = (end_dt - start_dt).total_seconds()
        if span <= 0: span = 1
        for k in range(falta):
            frac = (k + 1) / (falta + 1)
            t = start_dt + timedelta(seconds=frac * span)
            t += timedelta(milliseconds=1 + k)  # jitter
            base.append(t)
        base.sort()
        for i in range(1, len(base)):
            if base[i] <= base[i-1]:
                base[i] = base[i-1] + timedelta(milliseconds=2)
    else:
        base = base[:n]
    return base

# ---------- Cargar CSV de entrada ----------
ALUMNOS = ff("ALUMNO.csv","alumnos.csv","*ALUMNO*.csv","*alumnos*.csv")
FORM    = ff("formacion.csv","*FORMACION*.csv")
MPAGO   = ff("metodo_pago.csv","*METODO_PAGO*.csv")
if not ALUMNOS or not FORM or not MPAGO:
    raise FileNotFoundError("Faltan CSV: ALUMNO / FORMACION / METODO_PAGO en la carpeta del script.")

# ALUMNO
alumnos=[]
with open(ALUMNOS, newline="", encoding="utf-8") as f:
    rdr=csv.DictReader(f)
    for r in rdr:
        if not r.get("ID_ALUMNO"): continue
        fa = parse_dt(r.get("FECHA_ALTA",""))
        if fa:
            alumnos.append({"ID_ALUMNO": int(r["ID_ALUMNO"]), "FECHA_ALTA": fa})
if not alumnos: raise RuntimeError("ALUMNO sin FECHA_ALTA válidas")
alumnos.sort(key=lambda x: x["FECHA_ALTA"])
alumno_ids   = [a["ID_ALUMNO"] for a in alumnos]
alumno_by_id = {a["ID_ALUMNO"]: a for a in alumnos}
MIN_ALTA, MAX_ALTA = alumnos[0]["FECHA_ALTA"], alumnos[-1]["FECHA_ALTA"]

# FORMACION
precio_by_form = {}
form_ids = []
with open(FORM, newline="", encoding="utf-8") as f:
    rdr=csv.DictReader(f)
    for r in rdr:
        R={k.strip().upper(): (v or "").strip() for k,v in r.items()}
        if not R.get("ID_FORMACION"): continue
        fid = int(R["ID_FORMACION"]); form_ids.append(fid)
        val = R.get("PRECIO_ACTUAL","").replace(",", ".")
        try: precio_by_form[fid] = int(round(float(val)))
        except: precio_by_form[fid] = random.randint(120000, 900000)
if not form_ids: raise RuntimeError("FORMACION sin IDs")

# MÉTODO PAGO
metodos=[]
with open(MPAGO, newline="", encoding="utf-8") as f:
    rdr=csv.DictReader(f)
    for r in rdr:
        for k in r.keys():
            if k and "ID_METODO" in k.upper() and r.get(k):
                metodos.append(int(r[k])); break
if not metodos: raise RuntimeError("METODO_PAGO sin IDs")

# ---------- Ventana temporal ----------
WINDOW_START = MIN_ALTA
WINDOW_END   = MAX_ALTA + timedelta(days=30)   # margen razonable pos-alta

# =========================================================
# 1) FACTURA_CABECERA (emisiones por día, <= MAX_POR_DIA)
# =========================================================
base_emisiones = gen_emisiones_por_dia(
    N_FACTURAS, WINDOW_START, WINDOW_END - timedelta(days=25), max_por_dia=MAX_POR_DIA
)

cab_rows=[]
last_emision=None
last_venc=None

for i in range(1, N_FACTURAS+1):
    id_alumno = random.choice(alumno_ids)
    alta = alumno_by_id[id_alumno]["FECHA_ALTA"]
    base = base_emisiones[i-1]

    # mover emisión si cae antes de la alta del alumno
    emision = max(base, alta + timedelta(days=random.randint(0, 15), seconds=random.randint(0,3600)))
    emision = bump_after(emision, last_emision, 3)
    emision = min(emision, WINDOW_END - timedelta(days=12))

    # vencimiento con tope dinámico por fila (evita repetición de topes)
    dynamic_venc_cap = WINDOW_END - timedelta(milliseconds=(N_FACTURAS - i))
    venc_cand = emision + timedelta(days=random.randint(12,30), seconds=random.randint(0,3600))
    venc_cand = bump_after(venc_cand, last_venc, 3)
    venc = min(venc_cand, dynamic_venc_cap)

    # garantías mínimas
    min_allowed = max(emision + timedelta(seconds=1), (last_venc + timedelta(milliseconds=3)) if last_venc else emision)
    if venc < min_allowed: venc = min_allowed
    if venc > WINDOW_END:  venc = WINDOW_END

    cab_rows.append({
        "ID_FACTURA_CABECERA": i,
        "ID_ALUMNO": id_alumno,
        "ID_METODO_PAGO": random.choice(metodos),
        "MONTO_TOTAL": None,
        "FECHA_EMISION": emision,
        "FECHA_VENCIMIENTO": venc
    })
    last_emision, last_venc = emision, venc

# =========================================================
# 2) FACTURA_DETALLE (1–3 ítems)  — totales enteros
# =========================================================
det_rows=[]
id_det=1
for i in range(1, N_FACTURAS+1):
    r = random.random()
    k = 1 if r < 0.60 else (2 if r < 0.90 else 3)
    forms = random.sample(form_ids, k) if len(form_ids)>=k else [random.choice(form_ids) for _ in range(k)]
    total = 0
    for fid in forms:
        precio = precio_by_form.get(fid, random.randint(120000, 900000))
        desc   = int(round(precio * random.choice([0, 0.05, 0.10, 0.15, 0.20])))
        sub    = max(precio - desc, 0)
        det_rows.append({
            "ID_FACTURA_DETALLE": id_det,
            "ID_FACTURA_CABECERA": i,
            "ID_FORMACION": fid,
            "PRECIO": precio,
            "MONTO_DESCUENTO": desc,
            "SUBTOTAL": sub
        })
        id_det += 1
        total += sub
    cab_rows[i-1]["MONTO_TOTAL"] = total

# =========================================================
# 3) PAGO (1 por factura) — incremental y dentro [emisión, vencimiento]
# =========================================================
first_em = cab_rows[0]["FECHA_EMISION"]
last_ven = cab_rows[-1]["FECHA_VENCIMIENTO"]

# Base segura con EXACTAMENTE N_FACTURAS puntos (evita IndexError)
base_pagos = safe_base_series(N_FACTURAS, first_em, last_ven, max_por_dia=MAX_POR_DIA)

pago_rows = []
last_pago = None

for i in range(1, N_FACTURAS + 1):
    emision = cab_rows[i - 1]["FECHA_EMISION"]
    venc    = cab_rows[i - 1]["FECHA_VENCIMIENTO"]

    base = base_pagos[i - 1]

    # ventana [lo, hi] para el pago de esta factura
    lo = max(emision, (last_pago + timedelta(milliseconds=5)) if last_pago else emision)
    hi = min(venc, base + timedelta(hours=12))  # pago cercano a su base pero antes del venc
    if hi < lo: hi = lo

    # clamp de la base a [lo, hi]
    pago_dt = max(lo, min(base, hi))
    last_pago = pago_dt

    pago_rows.append({
        "ID_PAGO": i,
        "ID_FACTURA_CABECERA": cab_rows[i - 1]["ID_FACTURA_CABECERA"],
        "FECHA": pago_dt,
        "MONTO": cab_rows[i - 1]["MONTO_TOTAL"],
        "ID_METODO_PAGO": cab_rows[i - 1]["ID_METODO_PAGO"]
    })

# =========================================================
# 4) HISTORIAL_PRECIO (derivado de los detalles reales)
# =========================================================
emision_by_id = {c["ID_FACTURA_CABECERA"]: c["FECHA_EMISION"] for c in cab_rows}
events_by_form = {}
for d in det_rows:
    fid = d["ID_FORMACION"]
    fecha = emision_by_id[d["ID_FACTURA_CABECERA"]]
    precio = d["PRECIO"]
    events_by_form.setdefault(fid, []).append((fecha, precio))

periods=[]
for fid, evs in events_by_form.items():
    evs = sorted(evs, key=lambda x: (x[0], x[1]))
    cur_p = evs[0][1]
    cur_s = evs[0][0]
    for j in range(1, len(evs)):
        dt, p = evs[j]
        if p != cur_p:
            end = dt - timedelta(milliseconds=1)
            if end < cur_s: end = cur_s
            periods.append({"FID": fid, "P": cur_p, "DESDE": cur_s, "HASTA": end})
            cur_p, cur_s = p, dt
    periods.append({"FID": fid, "P": cur_p, "DESDE": cur_s, "HASTA": None})

# Orden y anti-solapes
periods.sort(key=lambda r: (r["DESDE"], r["FID"], r["P"]))
for i in range(1, len(periods)):
    if periods[i]["DESDE"] <= periods[i-1]["DESDE"]:
        periods[i]["DESDE"] = periods[i-1]["DESDE"] + timedelta(milliseconds=2)
    if periods[i-1]["HASTA"] is not None and periods[i-1]["HASTA"] >= periods[i]["DESDE"]:
        periods[i-1]["HASTA"] = periods[i]["DESDE"] - timedelta(milliseconds=2)
for r in periods:
    if r["HASTA"] and r["HASTA"] < r["DESDE"]:
        r["HASTA"] = r["DESDE"]

# ---------- Export ----------
CAB_OUT  = os.path.join(BASE_DIR, "factura_cabecera.csv")
DET_OUT  = os.path.join(BASE_DIR, "factura_detalle.csv")
PAGO_OUT = os.path.join(BASE_DIR, "pago.csv")
HIST_OUT = os.path.join(BASE_DIR, "historial_precio.csv")

with open(CAB_OUT,"w",newline="",encoding="utf-8") as f:
    w=csv.DictWriter(f,fieldnames=[
        "ID_FACTURA_CABECERA","ID_ALUMNO","ID_METODO_PAGO","MONTO_TOTAL",
        "FECHA_EMISION","FECHA_VENCIMIENTO"])
    w.writeheader()
    for r in cab_rows:
        w.writerow({
            "ID_FACTURA_CABECERA": r["ID_FACTURA_CABECERA"],
            "ID_ALUMNO": r["ID_ALUMNO"],
            "ID_METODO_PAGO": r["ID_METODO_PAGO"],
            "MONTO_TOTAL": to_int_str(r["MONTO_TOTAL"]),
            "FECHA_EMISION": fmt_ms(r["FECHA_EMISION"]),
            "FECHA_VENCIMIENTO": fmt_ms(r["FECHA_VENCIMIENTO"])
        })

with open(DET_OUT,"w",newline="",encoding="utf-8") as f:
    w=csv.DictWriter(f,fieldnames=[
        "ID_FACTURA_DETALLE","ID_FACTURA_CABECERA","ID_FORMACION",
        "PRECIO","MONTO_DESCUENTO","SUBTOTAL"])
    w.writeheader()
    for r in det_rows:
        w.writerow({
            "ID_FACTURA_DETALLE": r["ID_FACTURA_DETALLE"],
            "ID_FACTURA_CABECERA": r["ID_FACTURA_CABECERA"],
            "ID_FORMACION": r["ID_FORMACION"],
            "PRECIO": to_int_str(r["PRECIO"]),
            "MONTO_DESCUENTO": to_int_str(r["MONTO_DESCUENTO"]),
            "SUBTOTAL": to_int_str(r["SUBTOTAL"])
        })

with open(PAGO_OUT,"w",newline="",encoding="utf-8") as f:
    w=csv.DictWriter(f,fieldnames=["ID_PAGO","ID_FACTURA_CABECERA","FECHA","MONTO","ID_METODO_PAGO"])
    w.writeheader()
    for r in pago_rows:
        w.writerow({
            "ID_PAGO": r["ID_PAGO"],
            "ID_FACTURA_CABECERA": r["ID_FACTURA_CABECERA"],
            "FECHA": fmt_ms(r["FECHA"]),
            "MONTO": to_int_str(r["MONTO"]),
            "ID_METODO_PAGO": r["ID_METODO_PAGO"]
        })

with open(HIST_OUT,"w",newline="",encoding="utf-8") as f:
    w=csv.DictWriter(f,fieldnames=[
        "ID_HISTORIAL_PRECIO","ID_FORMACION","PRECIO","VIGENCIA_DESDE","VIGENCIA_HASTA"])
    w.writeheader()
    for i,r in enumerate(periods, start=1):
        w.writerow({
            "ID_HISTORIAL_PRECIO": i,
            "ID_FORMACION": r["FID"],
            "PRECIO": to_int_str(r["P"]),
            "VIGENCIA_DESDE": fmt_ms(r["DESDE"]),
            "VIGENCIA_HASTA": fmt_ms(r["HASTA"]) if r["HASTA"] else ""
        })

print(f"✅ OK — Cabeceras: {len(cab_rows)} | Detalles: {len(det_rows)} | Pagos: {len(pago_rows)} | Historial: {len(periods)}")
