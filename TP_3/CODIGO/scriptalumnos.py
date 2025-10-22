import csv
import random
from datetime import datetime, timedelta
from faker import Faker
import unicodedata

fake = Faker("es_AR")

# --- Parámetros generales ---
N = 200
window_start = datetime(2023, 10, 29, 0, 0, 0, 0)
window_end   = datetime(2025, 5, 30, 23, 59, 59, 999000)  # fin del día con ms
reference_today = datetime(2025, 5, 30, 23, 59, 59, 0)     # "hoy" para la edad

# --- Helpers ---
def normalize_str(s: str) -> str:
    s = ''.join(c for c in unicodedata.normalize('NFKD', s) if not unicodedata.combining(c))
    return s.replace("ñ", "n").replace("Ñ", "N")

def month_weight(month: int) -> int:
    # Picos en nov-dic y jun-jul
    return 3 if month in [11, 12, 6, 7] else 1

def month_iter(start: datetime, end: datetime):
    """Itera (año, mes, inicio_mes, fin_mes_inclusivo) dentro del rango dado."""
    y, m = start.year, start.month
    while True:
        start_m = datetime(y, m, 1)
        # siguiente mes
        ny, nm = (y+1, 1) if m == 12 else (y, m+1)
        next_m = datetime(ny, nm, 1)
        end_m = next_m - timedelta(milliseconds=1)

        # recortar contra ventana
        start_eff = max(start_m, start)
        end_eff = min(end_m, end)
        if start_eff <= end_eff:
            yield (y, m, start_eff, end_eff)

        if next_m > end:
            break
        y, m = ny, nm

def distribute_counts(total, months_weights):
    """Distribuye 'total' entre meses según pesos, ajustando el redondeo."""
    months, weights = zip(*months_weights)
    wsum = sum(weights)
    raw = [total * w / wsum for w in weights]
    base = [int(x) for x in raw]
    remaining = total - sum(base)
    # Asignar los restantes a los meses con mayores residuos
    residuals = sorted(
        list(enumerate([r - b for r, b in zip(raw, base)])),
        key=lambda x: x[1],
        reverse=True
    )
    for i in range(remaining):
        base[residuals[i][0]] += 1
    return dict(zip(months, base))

def random_time_in_day():
    """Devuelve un timedelta con hora:min:seg y milisegundos aleatorios."""
    seconds = random.randint(0, 23*3600 + 59*60 + 59)
    millis = random.randint(0, 999)
    return timedelta(seconds=seconds, milliseconds=millis)

def fmt_dt_ms(dt: datetime) -> str:
    # YYYY-MM-DD HH:MM:SS.mmm (milisegundos)
    return dt.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

# --- Construir lista de fechas de alta autoincrementales con tendencia ---
months_info = list(month_iter(window_start, window_end))  # (y, m, start_eff, end_eff)
months_weights = [(((y, m), month_weight(m))) for (y, m, _, _) in months_info]
counts = distribute_counts(N, months_weights)

fechas_alta = []
for (y, m, start_m, end_m) in months_info:
    cnt = counts.get((y, m), 0)
    if cnt <= 0:
        continue
    # distribuir dentro del mes, asegurando cobertura y orden aproximado
    span_days = (end_m - start_m).days
    for i in range(cnt):
        # ubicaciones crecientes dentro del mes (no uniformes puras, pero ordenadas)
        day_offset = int((i + 1) * (span_days / (cnt + 1)))
        base_day = start_m + timedelta(days=day_offset)
        # aleatorizar el tiempo dentro del día
        dt = base_day.replace(hour=0, minute=0, second=0, microsecond=0) + random_time_in_day()
        # clamp por si acaso
        if dt < start_m: dt = start_m
        if dt > end_m:   dt = end_m
        fechas_alta.append(dt)

# Ordenar y asegurar NO DECRECIENTE con ms aleatorios (y sin salir de la ventana)
fechas_alta.sort()
for i in range(1, len(fechas_alta)):
    if fechas_alta[i] <= fechas_alta[i-1]:
        candidate = fechas_alta[i-1] + timedelta(milliseconds=1)
        fechas_alta[i] = min(candidate, window_end)

# Si por redondeos hubiera más de N, recortamos a N (se mantiene orden)
fechas_alta = fechas_alta[:N]

# --- Generación de registros ---
rows = []
for i in range(1, N + 1):
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
        # edad 18-60
        edad_target = random.randint(18, 60)
    else:
        dni = random.randint(40_000_000, 47_000_000)
        numero_doc = str(dni)
        # Mapeo lineal: 40M -> 25 años, 47M -> 18 años
        edad_float = 25 - (dni - 40_000_000) * (7 / 7_000_000)
        edad_target = int(max(18, min(60, round(edad_float))))

    # Fecha de nacimiento consistente con "hoy" = 30/05/2025 y edad >= 18
    # Tomamos edad_target años y sumamos 0..364 días para variar el cumpleaños
    rnd_days = random.randint(0, 364)
    fecha_nac = (reference_today - timedelta(days=edad_target*365 + rnd_days)).date()

    fecha_alta = fechas_alta[i-1]
    fecha_baja = ""  # vacío

    rows.append([
        i, nombre, apellido, email, telefono, tipo_doc, numero_doc,
        fecha_nac.isoformat(), fmt_dt_ms(fecha_alta), fecha_baja
    ])

# --- Exportar CSV ---
with open("alumnos.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "ID_ALUMNO", "NOMBRE", "APELLIDO", "EMAIL", "TELEFONO",
        "TIPO_DOCUMENTO", "NUMERO_DOCUMENTO", "FECHA_NACIMIENTO",
        "FECHA_ALTA", "FECHA_BAJA"
    ])
    writer.writerows(rows)

print("✅ alumnos.csv generado con fechas/hora autoincrementales y edades >= 18.")
