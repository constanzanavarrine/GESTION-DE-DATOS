import csv
import os
import glob
from datetime import datetime, timedelta

# ----------------------------
# Archivos de entrada/salida
# ----------------------------
FORMACION_CAND     = ["formacion.csv", "*FORMACION*.csv"]
FACT_CAB_CAND      = ["factura_cabecera.csv", "*FACTURA_CABECERA*.csv"]
FACT_DET_CAND      = ["factura_detalle.csv", "*FACTURA_DETALLE*.csv"]
HISTORIAL_OUT      = "historial_precio.csv"

WINDOW_START = datetime(2023, 3, 3, 9, 0, 0, 0)
WINDOW_END   = datetime(2025, 5, 30, 23, 59, 59, 999000)

# ----------------------------
# Helpers
# ----------------------------
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

def parse_dt(s: str):
    if not s: return None
    s = s.strip()
    for fmt in ("%Y-%m-%d %H:%M:%S.%f","%Y-%m-%d %H:%M:%S","%Y-%m-%d","%d/%m/%Y"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            pass
    return None

def fmt_ms(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]  # con milisegundos

def to_int(x):
    if x is None or x == "": return 0
    if isinstance(x, (int, float)): return int(round(x))
    s = str(x).replace(",", ".")
    try: return int(round(float(s)))
    except: return 0

# ----------------------------
# Cargar insumos EXISTENTES
# ----------------------------
form_path = find_first(FORMACION_CAND) or "formacion.csv"
cab_path  = find_first(FACT_CAB_CAND)  or "factura_cabecera.csv"
det_path  = find_first(FACT_DET_CAND)  or "factura_detalle.csv"

if not os.path.exists(form_path): raise FileNotFoundError("No encontré FORMACION*.csv")
if not os.path.exists(cab_path):  raise FileNotFoundError("No encontré FACTURA_CABECERA*.csv")
if not os.path.exists(det_path):  raise FileNotFoundError("No encontré FACTURA_DETALLE*.csv")

# FORMACION: ID_FORMACION, PRECIO_ACTUAL (por si una formación no aparece en facturas)
form_by_id = {}
with open(form_path, newline="", encoding="utf-8") as f:
    rdr = csv.DictReader(f)
    for r in rdr:
        R = {k.strip().upper(): (v or "").strip() for k,v in r.items()}
        if not R.get("ID_FORMACION"): continue
        form_by_id[int(R["ID_FORMACION"])] = {
            "PRECIO_ACTUAL": to_int(R.get("PRECIO_ACTUAL")),
            "FECHA_ALTA": parse_dt(R.get("FECHA_ALTA","")) or WINDOW_START
        }

# FACTURA_CABECERA: ID, FECHA_EMISION
emision_by_cab = {}
with open(cab_path, newline="", encoding="utf-8") as f:
    rdr = csv.DictReader(f)
    for r in rdr:
        emision_by_cab[int(r["ID_FACTURA_CABECERA"])] = parse_dt(r["FECHA_EMISION"])

# FACTURA_DETALLE: ID_FACTURA_CABECERA, ID_FORMACION, PRECIO
# -> eventos de (fecha_emision, precio) por formación
events_by_form = {}
with open(det_path, newline="", encoding="utf-8") as f:
    rdr = csv.DictReader(f)
    for r in rdr:
        id_cab  = int(r["ID_FACTURA_CABECERA"])
        id_form = int(r["ID_FORMACION"])
        precio  = to_int(r["PRECIO"])
        fecha   = emision_by_cab.get(id_cab)
        if not fecha:
            continue
        events_by_form.setdefault(id_form, []).append((fecha, precio))

# ----------------------------
# Construir periodos por formación
# ----------------------------
periods = []  # lista de dicts con ID_FORMACION, PRECIO, DESDE, HASTA
for id_form, base in form_by_id.items():
    # Ordenar eventos por fecha y eliminar duplicados exactos por misma fecha y precio
    evs = sorted(events_by_form.get(id_form, []), key=lambda x: (x[0], x[1]))
    # Si no hay eventos, crear un único periodo abierto con PRECIO_ACTUAL (o 0 si no hay)
    if not evs:
        start = max(base["FECHA_ALTA"], WINDOW_START)
        periods.append({
            "ID_FORMACION": id_form,
            "PRECIO": base["PRECIO_ACTUAL"] if base["PRECIO_ACTUAL"]>0 else 0,
            "DESDE": start,
            "HASTA": None
        })
        continue

    # Comprimir por cambios de precio
    # Primer periodo arranca en la fecha del primer evento
    current_price = evs[0][1]
    current_start = max(evs[0][0], WINDOW_START)

    for i in range(1, len(evs)):
        dt, p = evs[i]
        dt = max(dt, WINDOW_START)
        if p != current_price:
            # cerrar periodo anterior hasta el instante previo al cambio
            end = dt - timedelta(milliseconds=1)
            if end < current_start:
                end = current_start  # evitar negativos (raro, pero seguro)
            periods.append({
                "ID_FORMACION": id_form,
                "PRECIO": current_price,
                "DESDE": current_start,
                "HASTA": min(end, WINDOW_END)
            })
            # iniciar nuevo
            current_price = p
            current_start = dt

    # último periodo abierto
    periods.append({
        "ID_FORMACION": id_form,
        "PRECIO": current_price,
        "DESDE": current_start,
        "HASTA": None
    })

# ----------------------------
# Ordenar globalmente y asegurar incrementalidad estricta
# ----------------------------
periods.sort(key=lambda r: (r["DESDE"], r["ID_FORMACION"], r["PRECIO"]))
for i in range(1, len(periods)):
    if periods[i]["DESDE"] <= periods[i-1]["DESDE"]:
        periods[i]["DESDE"] = periods[i-1]["DESDE"] + timedelta(milliseconds=1)
    # ajustar HASTA anterior si solapa
    if periods[i-1]["HASTA"] is not None and periods[i-1]["HASTA"] >= periods[i]["DESDE"]:
        periods[i-1]["HASTA"] = periods[i]["DESDE"] - timedelta(milliseconds=1)

# clamp a ventana y coherencia DESDE<=HASTA
for r in periods:
    r["DESDE"] = max(r["DESDE"], WINDOW_START)
    if r["HASTA"]:
        r["HASTA"] = min(r["HASTA"], WINDOW_END)
        if r["HASTA"] < r["DESDE"]:
            r["HASTA"] = r["DESDE"]

# Reasignar IDs
for i, r in enumerate(periods, start=1):
    r["ID_HISTORIAL_PRECIO"] = i

# ----------------------------
# Exportar CSV
# ----------------------------
with open(HISTORIAL_OUT, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=[
        "ID_HISTORIAL_PRECIO","ID_FORMACION","PRECIO","VIGENCIA_DESDE","VIGENCIA_HASTA"
    ])
    w.writeheader()
    for r in periods:
        w.writerow({
            "ID_HISTORIAL_PRECIO": r["ID_HISTORIAL_PRECIO"],
            "ID_FORMACION": r["ID_FORMACION"],
            "PRECIO": str(int(r["PRECIO"])),               # ENTERO
            "VIGENCIA_DESDE": fmt_ms(r["DESDE"]),
            "VIGENCIA_HASTA": fmt_ms(r["HASTA"]) if r["HASTA"] else ""
        })

print(f"✅ Generado {os.path.abspath(HISTORIAL_OUT)} con {len(periods)} filas, consistente con Facturas/Detalles.")
