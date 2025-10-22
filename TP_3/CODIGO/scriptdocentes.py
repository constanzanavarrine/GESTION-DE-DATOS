import csv
import random
from datetime import datetime, timedelta
from faker import Faker
import unicodedata

fake = Faker("es_AR")

# --- Parámetros ---
N_TOTAL = 100
N_W1, N_W2, N_W3 = 80, 10, 10  # 2023/01-07, 2024/01-02, 2025/01-02
reference_today = datetime(2025, 5, 30, 23, 59, 59, 0)  # para edad >= 18

# Ventanas de altas
W1_START = datetime(2023, 1, 1, 0, 0, 0, 0)
W1_END   = datetime(2023, 7, 31, 23, 59, 59, 999000)
W2_START = datetime(2024, 1, 1, 0, 0, 0, 0)
W2_END   = datetime(2024, 2, 29, 23, 59, 59, 999000)  # 2024 es bisiesto
W3_START = datetime(2025, 1, 1, 0, 0, 0, 0)
W3_END   = datetime(2025, 2, 28, 23, 59, 59, 999000)
GLOBAL_END = W3_END

# --- Helpers ---
def normalize_str(s: str) -> str:
    s = ''.join(c for c in unicodedata.normalize('NFKD', s) if not unicodedata.combining(c))
    return s.replace("ñ", "n").replace("Ñ", "N")

def month_iter(start: datetime, end: datetime):
    """Itera (y, m, inicio_efectivo, fin_efectivo) por meses dentro del rango."""
    y, m = start.year, start.month
    while True:
        start_m = datetime(y, m, 1)
        ny, nm = (y + 1, 1) if m == 12 else (y, m + 1)
        next_m = datetime(ny, nm, 1)
        end_m = next_m - timedelta(milliseconds=1)

        start_eff = max(start_m, start)
        end_eff = min(end_m, end)
        if start_eff <= end_eff:
            yield (y, m, start_eff, end_eff)

        if next_m > end:
            break
        y, m = ny, nm

def distribute_counts(total, months_weights):
    """Distribuye 'total' según pesos, ajustando redondeo por residuales."""
    months, weights = zip(*months_weights)
    wsum = sum(weights)
    raw = [total * w / wsum for w in weights]
    base = [int(x) for x in raw]
    remaining = total - sum(base)
    residuals = sorted(
        list(enumerate([r - b for r, b in zip(raw, base)])),
        key=lambda x: x[1],
        reverse=True
    )
    for i in range(remaining):
        base[residuals[i][0]] += 1
    return dict(zip(months, base))

def random_time_in_day():
    seconds = random.randint(0, 23*3600 + 59*60 + 59)
    millis = random.randint(0, 999)
    return timedelta(seconds=seconds, milliseconds=millis)

def fmt_dt_ms(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

def build_dates_for_window(start_dt, end_dt, count, weight_fn):
    """Genera 'count' fechas dentro [start_dt, end_dt] con pesos por mes y horas aleatorias."""
    months_info = list(month_iter(start_dt, end_dt))  # (y, m, start_eff, end_eff)
    months_weights = [(((y, m), weight_fn(m))) for (y, m, _, _) in months_info]
    counts = distribute_counts(count, months_weights)

    fechas = []
    for (y, m, start_m, end_m) in months_info:
        cnt = counts.get((y, m), 0)
        if cnt <= 0:
            continue
        span_days = max(1, (end_m.date() - start_m.date()).days)  # evitar div/0
        for i in range(cnt):
            day_offset = int((i + 1) * (span_days / (cnt + 1)))
            base_day = start_m + timedelta(days=day_offset)
            dt = base_day.replace(hour=0, minute=0, second=0, microsecond=0) + random_time_in_day()
            if dt < start_m: dt = start_m
            if dt > end_m:   dt = end_m
            fechas.append(dt)
    return fechas

def ensure_strictly_increasing(dts, max_dt):
    """Ordena y fuerza incremento estricto (+1ms si es necesario) sin pasar max_dt."""
    dts.sort()
    for i in range(1, len(dts)):
        if dts[i] <= dts[i-1]:
            dts[i] = min(dts[i-1] + timedelta(milliseconds=1), max_dt)
    return dts

# --- Pesos de mes por ventana ---
# W1 (ene–jul 2023): picos en jun–jul
def weight_w1(month: int) -> int:
    return 3 if month in (6, 7) else 1

# W2 y W3 (ene–feb): sin preferencia especial
def weight_w2w3(month: int) -> int:
    return 1

# --- Fechas de alta para DOCENTES ---
fechas_w1 = build_dates_for_window(W1_START, W1_END, N_W1, weight_w1)
fechas_w2 = build_dates_for_window(W2_START, W2_END, N_W2, weight_w2w3)
fechas_w3 = build_dates_for_window(W3_START, W3_END, N_W3, weight_w2w3)

fechas_alta = fechas_w1 + fechas_w2 + fechas_w3
fechas_alta = ensure_strictly_increasing(fechas_alta, GLOBAL_END)
fechas_alta = fechas_alta[:N_TOTAL]

# --- Generación de registros DOCENTE ---
rows = []
for i in range(1, N_TOTAL + 1):
    nombre = normalize_str(fake.first_name())
    apellido = normalize_str(fake.last_name())
    email = f"{nombre.lower()}.{apellido.lower()}@gmail.com"
    telefono = f"+54 911 {random.randint(1000,9999)}-{random.randint(1000,9999)}"

    tipo_doc = "PASAPORTE" if random.random() < 0.9 else "DNI"
    if tipo_doc == "PASAPORTE":
        numero_doc = (
            "".join(random.choices("ABCDEFGHIJKLMNOPQRSTUVWXYZ", k=3)) +
            "".join(random.choices("0123456789", k=6))
        )
        edad_target = random.randint(18, 60)
    else:
        dni = random.randint(40_000_000, 47_000_000)
        numero_doc = str(dni)
        edad_float = 25 - (dni - 40_000_000) * (7 / 7_000_000)  # 40M->25, 47M->18
        edad_target = int(max(18, min(60, round(edad_float))))

    # Fecha de nacimiento (>= 18 al 30/05/2025)
    rnd_days = random.randint(0, 364)
    fecha_nac = (reference_today - timedelta(days=edad_target*365 + rnd_days)).date()

    fecha_alta = fechas_alta[i-1]
    fecha_baja = ""  # vacío

    rows.append([
        i, nombre, apellido, email, telefono, tipo_doc, numero_doc,
        fecha_nac.isoformat(), fmt_dt_ms(fecha_alta), fecha_baja
    ])

# --- Exportar CSV ---
with open("docentes.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "ID_DOCENTE", "NOMBRE", "APELLIDO", "EMAIL", "TELEFONO",
        "TIPO_DOCUMENTO", "NUMERO_DOCUMENTO", "FECHA_NACIMIENTO",
        "FECHA_ALTA", "FECHA_BAJA"
    ])
    writer.writerows(rows)

print("✅ docentes.csv generado con 80 altas en 2023/01-07, 10 en 2024/01-02 y 10 en 2025/01-02, orden estricto y hh:mm:ss.mmm aleatorios.")
