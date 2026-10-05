#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

cd ~/Desktop/Post-Doctorado/Articulos\ en\ proceso/AMP_totoaba/review/01_busquedas/

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  DEDUPLICACIÓN GLOBAL${NC}"
echo -e "${BLUE}========================================${NC}\n"

# -----------------------------------------------------------------------------
# 1. EXTRAER DOIs DE TODOS LOS RIS
# -----------------------------------------------------------------------------
echo -e "${BLUE}[1/5] Extrayendo DOIs de todos los RIS...${NC}"

# Función para extraer DOIs normalizados
extraer_dois() {
    grep "^DO  -" "$1" | sed 's/^DO  - //' | tr '[:upper:]' '[:lower:]' | sort -u
}

extraer_dois scopus_pista_A_2026-10-02.ris > /tmp/A_orig.txt
extraer_dois scopus_pista_B_2026-10-02.ris > /tmp/B_orig.txt
extraer_dois scopus_pista_A_refinada_2026-10-02.ris > /tmp/A_ref.txt
extraer_dois scopus_pista_B_refinada_2026-10-02.ris > /tmp/B_ref.txt

echo "  A original:   $(wc -l < /tmp/A_orig.txt)"
echo "  B original:   $(wc -l < /tmp/B_orig.txt)"
echo "  A refinada:   $(wc -l < /tmp/A_ref.txt)"
echo "  B refinada:   $(wc -l < /tmp/B_ref.txt)"

# -----------------------------------------------------------------------------
# 2. CONJUNTO PREVIO (A orig + B orig) = 199 originales cribados
# -----------------------------------------------------------------------------
cat /tmp/A_orig.txt /tmp/B_orig.txt | sort -u > /tmp/PREVIO_ORIGINAL.txt
echo ""
echo "  Conjunto previo original (A orig + B orig): $(wc -l < /tmp/PREVIO_ORIGINAL.txt)"

# -----------------------------------------------------------------------------
# 3. NUEVOS DE A REFINADA (restando TODO lo anterior)
# -----------------------------------------------------------------------------
comm -23 /tmp/A_ref.txt /tmp/PREVIO_ORIGINAL.txt > /tmp/A_ref_NUEVOS.txt
echo "  Nuevos de A refinada (vs original): $(wc -l < /tmp/A_ref_NUEVOS.txt)"

# -----------------------------------------------------------------------------
# 4. NUEVOS DE B REFINADA (restando original + A refinada)
# -----------------------------------------------------------------------------
# Restar PREVIO_ORIGINAL y A_ref completa
cat /tmp/PREVIO_ORIGINAL.txt /tmp/A_ref.txt | sort -u > /tmp/PREVIO_MAS_A_REF.txt
comm -23 /tmp/B_ref.txt /tmp/PREVIO_MAS_A_REF.txt > /tmp/B_ref_NUEVOS.txt

echo "  Nuevos de B refinada (vs original + A refinada): $(wc -l < /tmp/B_ref_NUEVOS.txt)"

# -----------------------------------------------------------------------------
# 5. VERIFICAR OVERLAP ENTRE A_ref y B_ref
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}[2/5] Analizando overlap entre A refinada y B refinada...${NC}"

comm -12 /tmp/A_ref.txt /tmp/B_ref.txt > /tmp/A_ref_y_B_ref_overlap.txt
echo "  DOIs en AMBAS refinadas: $(wc -l < /tmp/A_ref_y_B_ref_overlap.txt)"

# -----------------------------------------------------------------------------
# 6. NUEVOS ÚNICOS TOTALES
# -----------------------------------------------------------------------------
cat /tmp/A_ref_NUEVOS.txt /tmp/B_ref_NUEVOS.txt | sort -u > /tmp/NUEVOS_UNICOS_TOTALES.txt

N_A_NUEVOS=$(wc -l < /tmp/A_ref_NUEVOS.txt)
N_B_NUEVOS=$(wc -l < /tmp/B_ref_NUEVOS.txt)
N_TOTAL_NUEVOS=$(wc -l < /tmp/NUEVOS_UNICOS_TOTALES.txt)
N_OVERLAP=$(wc -l < /tmp/A_ref_y_B_ref_overlap.txt)

echo ""
echo -e "${GREEN}=== RESUMEN GLOBAL ===${NC}"
echo "  Nuevos de A refinada: $N_A_NUEVOS"
echo "  Nuevos de B refinada: $N_B_NUEVOS"
echo "  Overlap A_ref/B_ref (ya no cuentan como nuevos): $N_OVERLAP"
echo "  ------------------------------------------"
echo "  TOTAL nuevos únicos: $N_TOTAL_NUEVOS"
echo "  ------------------------------------------"
echo ""

# -----------------------------------------------------------------------------
# 7. VERIFICAR SI LOS 52 DE B REFINADA ESTÁN EN A REFINADA
# -----------------------------------------------------------------------------
echo -e "${BLUE}[3/5] Detectando cuántos de los 52 'nuevos' de B_ref ya están en A_ref...${NC}"

# Leer los 52 que extrajimos antes (del análisis anterior)
if [ -f dois_acumulados/dois_A_nuevos.txt ]; then
    # El archivo anterior tenía los "nuevos" de A
    : # ignorar
fi

# Tomar los DOIs que en el análisis anterior se marcaron como "nuevos" de B_ref
# (ya no podemos recuperarlos, así que recalculamos)
cat /tmp/B_ref.txt | while read doi; do
    if grep -q "^$doi$" /tmp/A_ref.txt; then
        echo "  ⚠️  $doi está en A_ref"
    fi
done | head -20

# Contar cuántos de B_ref están en A_ref
N_B_REF_EN_A_REF=$(comm -12 /tmp/A_ref.txt /tmp/B_ref.txt | wc -l)
echo ""
echo "  De los 98 DOIs de B_ref, $N_B_REF_EN_A_REF también están en A_ref"

# -----------------------------------------------------------------------------
# 8. RE-EXTRAER LOS RIS FINALES DE NUEVOS
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}[4/5] Re-exportando RIS con nuevos únicos...${NC}"

# A refinada nuevos
python3 << 'PYEOF'
import re

with open("/tmp/A_ref_NUEVOS.txt") as f:
    dois = set(line.strip() for line in f if line.strip())

with open("scopus_pista_A_refinada_2026-10-02.ris", 'r', encoding='utf-8') as f:
    contenido = f.read()

registros = re.split(r'(?=^TY  -)', contenido, flags=re.MULTILINE)
nuevos = []
for reg in registros:
    if reg.strip().startswith('TY  -'):
        match = re.search(r'^DO  - (.+)$', reg, re.MULTILINE)
        if match and match.group(1).strip().lower() in dois:
            if not reg.endswith('\n'):
                reg += '\n'
            nuevos.append(reg)

with open("scopus_pista_A_refinada_NUEVOS.ris", 'w', encoding='utf-8') as f:
    f.write(''.join(nuevos))

print(f"A_ref nuevos: {len(nuevos)} artículos")
PYEOF

# B refinada nuevos
python3 << 'PYEOF'
import re

with open("/tmp/B_ref_NUEVOS.txt") as f:
    dois = set(line.strip() for line in f if line.strip())

with open("scopus_pista_B_refinada_2026-10-02.ris", 'r', encoding='utf-8') as f:
    contenido = f.read()

registros = re.split(r'(?=^TY  -)', contenido, flags=re.MULTILINE)
nuevos = []
for reg in registros:
    if reg.strip().startswith('TY  -'):
        match = re.search(r'^DO  - (.+)$', reg, re.MULTILINE)
        if match and match.group(1).strip().lower() in dois:
            if not reg.endswith('\n'):
                reg += '\n'
            nuevos.append(reg)

with open("scopus_pista_B_refinada_NUEVOS.ris", 'w', encoding='utf-8') as f:
    f.write(''.join(nuevos))

print(f"B_ref nuevos: {len(nuevos)} artículos")
PYEOF

# -----------------------------------------------------------------------------
# 9. COMBINAR TODO EN UN SOLO RIS
# -----------------------------------------------------------------------------
echo ""
echo -e "${BLUE}[5/5] Generando RIS combinado de nuevos únicos...${NC}"

cat scopus_pista_A_refinada_NUEVOS.ris scopus_pista_B_refinada_NUEVOS.ris > scopus_NUEVOS_COMBINADOS.ris

# Verificar
N_A_FINAL=$(grep -c "^TY  -" scopus_pista_A_refinada_NUEVOS.ris)
N_B_FINAL=$(grep -c "^TY  -" scopus_pista_B_refinada_NUEVOS.ris)
N_COMBINADO=$(grep -c "^TY  -" scopus_NUEVOS_COMBINADOS.ris)

echo ""
echo -e "${GREEN}=== ARCHIVOS FINALES ===${NC}"
echo "  scopus_pista_A_refinada_NUEVOS.ris:  $N_A_FINAL artículos"
echo "  scopus_pista_B_refinada_NUEVOS.ris:  $N_B_FINAL artículos"
echo "  scopus_NUEVOS_COMBINADOS.ris:        $N_COMBINADO artículos"
echo ""
echo -e "${GREEN}  TOTAL a cribar: $N_COMBINADO artículos únicos${NC}"
echo ""
echo -e "${BLUE}Próximo paso:${NC}"
echo "  Sube scopus_NUEVOS_COMBINADOS.ris a Rayyan"
