# Regenerar modulo.csv y unidad.csv con nombres "oficiales" tomados de páginas de Coderhouse.
# Requisitos:
# - programa.csv (30 programas). Si no existe, lo crea desde FORMACION*.csv en la misma carpeta.
# - Ejecutar donde vivan los CSV (ajusta paths si hace falta).

import csv, os, random, re, glob
from datetime import datetime, timedelta
from typing import List, Dict

random.seed(42)

PROGRAMA_CSV_IN = "programa.csv"
MODULO_CSV_OUT  = "modulo.csv"
UNIDAD_CSV_OUT  = "unidad.csv"

def dificultad_por_orden(orden: int) -> str:
    if orden == 1: return "BAJA"
    if orden in (2,3,4): return "MEDIA"
    return "ALTA"

def ensure_programa_from_formacion(out_path: str, n: int = 30):
    candidates = [p for p in glob.glob("*FORMACION*.csv")]
    if not candidates:
        raise FileNotFoundError("No hay FORMACION*.csv para generar programa.csv")
    form_path = sorted(candidates)[0]
    rows = []
    with open(form_path, newline="", encoding="utf-8") as f:
        rdr = csv.DictReader(f)
        for raw in rdr:
            r = {k.strip().upper(): (v or "").strip() for k,v in raw.items()}
            if "ID_FORMACION" in r and "NOMBRE" in r:
                rows.append({"ID_FORMACION": r["ID_FORMACION"], "NOMBRE": r["NOMBRE"]})
    if len(rows) < n:
        raise RuntimeError(f"FORMACION tiene {len(rows)} filas; se necesitan al menos {n}.")
    rows_sorted = sorted(rows, key=lambda x: int(x["ID_FORMACION"]))[:n]
    start = datetime(2023,3,3,9,0,0)
    fechas = []
    cur = start
    for i in range(n):
        cur += timedelta(days=5 + (i%3), hours=(i*7)%13, minutes=(i*17)%53, seconds=(i*29)%47)
        if i>0 and cur <= fechas[-1]:
            cur = fechas[-1] + timedelta(seconds=1)
        fechas.append(cur)
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["ID_PROGRAMA","ID_FORMACION","NOMBRE","FECHA_ALTA","FECHA_BAJA"])
        w.writeheader()
        for i, fr in enumerate(rows_sorted, start=1):
            w.writerow({
                "ID_PROGRAMA": i,
                "ID_FORMACION": int(fr["ID_FORMACION"]),
                "NOMBRE": f"Programa de {fr['NOMBRE']}",
                "FECHA_ALTA": fechas[i-1].strftime("%Y-%m-%d %H:%M:%S"),
                "FECHA_BAJA": ""
            })
    return out_path

if not os.path.exists(PROGRAMA_CSV_IN):
    ensure_programa_from_formacion(PROGRAMA_CSV_IN, n=30)

programas = []
with open(PROGRAMA_CSV_IN, newline="", encoding="utf-8") as f:
    rdr = csv.DictReader(f)
    for row in rdr:
        r = {k.strip().upper(): (v or "").strip() for k,v in row.items()}
        if "ID_PROGRAMA" in r and "NOMBRE" in r:
            programas.append({"ID_PROGRAMA": int(r["ID_PROGRAMA"]), "NOMBRE": r["NOMBRE"]})
if len(programas) < 30:
    raise RuntimeError(f"Se esperaban 30 programas en programa.csv, pero hay {len(programas)}.")
programas = sorted(programas, key=lambda x: x["ID_PROGRAMA"])[:30]

COURSES: Dict[str, Dict[str, List[str]]] = {
    "UXUI": {
        "module_name": "Curso de Diseño UX/UI",
        "units": [
            "Introducción al diseño",
            "Metodologías de Diseño y UX Research",
            "Entendiendo al Usuario en Diseño UX/UI",
            "Avanzando en UX/UI: De la Teoría a la Práctica",
            "Diseño y Optimización de Flujos de Usuario en UX",
            "Fundamentos y Aplicación de Wireframes en Diseño UX/UI",
            "Prototipar: Técnicas de diseño",
            "Diseño UX/UI Atomic Design en UX/UI",
            "Métricas y Leyes de UX",
            "Evaluación heurística y Construcción de Design System interactivo",
            "Diseño UX/UI - Pruebas de Usabilidad y Accesibilidad",
            "Ética en el Diseño UX/UI",
            "Presentación de Proyectos UX/UI",
        ],
    },
    "DS1": {
        "module_name": "Curso de Data Science I: Fundamentos para la Ciencia de Datos",
        "units": [
            "La Transformación Digital en la Industria 4.0",
            "Fundamentos de Python",
            "NumPy y Pandas",
            "Manipulación de Datos: Pandas",
            "Visualizaciones Avanzadas en Data Science",
            "Estadística y Preprocesamiento",
            "Aprendizaje Supervisado en Ciencia de Datos",
            "Aprendizaje No Supervisado",
            "Fundamentos de IA y Machine Learning",
            "Aplicaciones Prácticas de ML",
        ],
    },
    "BA": {
        "module_name": "Curso de Business Analytics",
        "units": [
            "Introducción a Business Analytics",
            "Modelos de Negocio, KPIs vs Métricas",
            "BI y Análisis Descriptivo",
            "Análisis Predictivo y Gráficos",
            "Herramientas de Business Analytics",
            "Tablas, Automatización y Storytelling",
            "Life Product Cycle y Experimentación",
            "Roadmaps y Workshop Final",
            "IA aplicada en Business Analytics",
        ],
    },
    "PM": {
        "module_name": "Curso de Product Manager",
        "units": [
            "Introducción al Product Management",
            "El Usuario al Centro de la Estrategia",
            "Validando tu producto",
            "Gestión del Product Backlog y Historias de Usuario en SCRUM",
            "Detalles para el desarrollo de un producto",
            "Pre-Producción y Modelos de Negocio",
            "Diseño UX / UI",
            "Fundamentos del Marketing Digital y Estrategias Avanzadas",
        ],
    },
    "MKT": {
        "module_name": "Curso de Fundamentos del Marketing digital",
        "units": [
            "Cómo crear un Plan de Marketing digital desde cero",
            "El rol clave del Community Manager profesional",
            "Estrategia de contenidos para Facebook e Instagram",
            "TikTok, Threads e Instagram Reels: Contenido que atrapa",
            "Marketing de contenidos para X (Twitter), LinkedIn y WhatsApp Business",
            "Cómo crear y gestionar anuncios en redes sociales (Meta Ads)",
            "Estrategias de Video Marketing y Publicidad en Google Ads",
            "Anuncios en Google Ads: Búsqueda, Display y Performance Max",
            "Remarketing y Analítica con Google Analytics",
            "Estrategias efectivas de Email Marketing",
        ],
    },
}

def classify_program(name: str) -> str:
    n = (name or "").lower()
    if any(k in n for k in ["ux", "ui", "figma", "dise\u00f1o"]): return "UXUI"
    if any(k in n for k in ["data science", "machine learning", "ml", "numpy", "pandas", "ciencia de datos"]): return "DS1"
    if any(k in n for k in ["analytics", "anal\u00edtica", "power bi", "bi ", "excel", "tableau", "looker"]): return "BA"
    if any(k in n for k in ["product", "producto", "pm "]): return "PM"
    if any(k in n for k in ["marketing", "seo", "ads", "social media", "community"]): return "MKT"
    return random.choice(list(COURSES.keys()))

modulos_rows, unidades_rows = [], []
for i, prog in enumerate(programas, start=1):
    category = classify_program(prog["NOMBRE"])
    course = COURSES[category]
    orden_mod = random.randint(1, 6)
    modulos_rows.append({
        "ID_MODULO": i,
        "ID_PROGRAMA": prog["ID_PROGRAMA"],
        "NOMBRE": course["module_name"],
        "ORDEN": orden_mod,
        "DIFICULTAD": dificultad_por_orden(orden_mod)
    })
    units = course["units"]
    u_index = (i - 1) % len(units)
    unidad_nombre = units[u_index]
    m = re.search(r"(\d+)", unidad_nombre)
    ord_candidate = max(1, min(6, int(m.group(1)))) if m else (u_index % 6) + 1
    unidades_rows.append({
        "ID_UNIDAD": i,
        "ID_PROGRAMA": prog["ID_PROGRAMA"],
        "ID_MODULO": i,
        "NOMBRE": unidad_nombre,
        "ORDEN": ord_candidate,
        "DIFICULTAD": dificultad_por_orden(ord_candidate)
    })

with open(MODULO_CSV_OUT, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["ID_MODULO","ID_PROGRAMA","NOMBRE","ORDEN","DIFICULTAD"])
    w.writeheader()
    w.writerows(modulos_rows)

with open(UNIDAD_CSV_OUT, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=["ID_UNIDAD","ID_PROGRAMA","ID_MODULO","NOMBRE","ORDEN","DIFICULTAD"])
    w.writeheader()
    w.writerows(unidades_rows)

print("OK ->", MODULO_CSV_OUT, UNIDAD_CSV_OUT)
