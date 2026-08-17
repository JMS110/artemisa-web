#!/bin/bash
# publicar-artemisa.sh
#
# Sincroniza fotos nuevas del NAS, las optimiza (WebP + resize a 1920px max),
# regenera el catálogo de imágenes en el repo Astro y hace commit + push.
# Vercel desplegará automáticamente al recibir el push.
#
# Uso:
#   ./scripts/publicar-artemisa.sh                 # sincroniza, optimiza, commit + push
#   ./scripts/publicar-artemisa.sh --dry-run       # solo muestra qué haría, sin cambios
#   ./scripts/publicar-artemisa.sh --no-push       # commit local pero sin push
#   ./scripts/publicar-artemisa.sh --no-move       # NO mueve originales a _procesadas/ en NAS

set -euo pipefail

# ============================================================================
# CONFIG
# ============================================================================
NAS_HOST="nas"
NAS_SRC="/volume1/Web-Artemisa"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMG_DIR="$REPO_DIR/public/images"
CATALOG_TS="$REPO_DIR/src/data/catalog.ts"
CATEGORIAS=(ramos centros bodas plantas coronas flor-seca eventos)
MAX_WIDTH=1920
WEBP_QUALITY=82

TMP_DIR="$(mktemp -d -t artemisa-sync)"
trap 'rm -rf "$TMP_DIR"' EXIT

# ============================================================================
# FLAGS
# ============================================================================
DRY_RUN=0
DO_PUSH=1
MOVE_PROCESADAS=1
for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=1; DO_PUSH=0; MOVE_PROCESADAS=0 ;;
    --no-push)  DO_PUSH=0 ;;
    --no-move)  MOVE_PROCESADAS=0 ;;
    -h|--help)
      grep -E '^# ' "$0" | head -20 | sed 's/^# //'
      exit 0
      ;;
  esac
done

# ============================================================================
# PRECHECKS
# ============================================================================
for cmd in sips cwebp rsync ssh git; do
  command -v "$cmd" >/dev/null || { echo "ERROR: falta $cmd"; exit 1; }
done
[ -d "$REPO_DIR/.git" ] || { echo "ERROR: no es un repo git: $REPO_DIR"; exit 1; }

# ============================================================================
# 1. DESCARGAR FOTOS PENDIENTES DEL NAS
# ============================================================================
echo "▶ Descargando fotos del NAS ($NAS_HOST:$NAS_SRC)..."
for cat in "${CATEGORIAS[@]}"; do
  mkdir -p "$TMP_DIR/$cat"
  # -q silencioso; solo bajamos categorías (no _procesadas)
  rsync -a --quiet "$NAS_HOST:$NAS_SRC/$cat/" "$TMP_DIR/$cat/" 2>/dev/null || true
done

# ============================================================================
# 2. OPTIMIZAR (resize + WebP) CADA FOTO NUEVA
# ============================================================================
TOTAL=0
declare -a PROCESADAS

for cat in "${CATEGORIAS[@]}"; do
  cat_tmp="$TMP_DIR/$cat"
  cat_web="$IMG_DIR/$cat"
  [ -d "$cat_tmp" ] || continue
  mkdir -p "$cat_web"

  # shellcheck disable=SC2231
  for src in "$cat_tmp"/*; do
    [ -f "$src" ] || continue
    base="$(basename "$src")"
    ext_low="$(echo "${base##*.}" | tr '[:upper:]' '[:lower:]')"
    # Solo imágenes
    case "$ext_low" in
      jpg|jpeg|png|heic|heif) ;;
      *) continue ;;
    esac

    name_no_ext="${base%.*}"
    webp_out="$cat_web/${name_no_ext}.webp"

    # Ya procesada → saltar
    if [ -f "$webp_out" ]; then
      continue
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  [dry-run] procesaría $cat/$base → ${name_no_ext}.webp"
      TOTAL=$((TOTAL+1))
      continue
    fi

    echo "  → $cat/$base"

    # Paso 1: HEIC → JPG intermedio si es necesario
    input_for_sips="$src"
    intermediate=""
    if [[ "$ext_low" == "heic" || "$ext_low" == "heif" ]]; then
      intermediate="$TMP_DIR/.heic-conv-$$.jpg"
      sips -s format jpeg "$src" --out "$intermediate" >/dev/null
      input_for_sips="$intermediate"
    fi

    # Paso 2: resize (mantiene aspecto, solo si ancho > MAX_WIDTH)
    resized="$TMP_DIR/.resized-$$.jpg"
    # sips no soporta "resize solo si mayor" nativamente; usamos --resampleWidth
    # que redimensiona a ese ancho (o más pequeño si aspecto lo requiere).
    # Para no ampliar fotos pequeñas comprobamos primero:
    orig_w=$(sips -g pixelWidth "$input_for_sips" | awk '/pixelWidth/{print $2}')
    if [ "${orig_w:-0}" -gt "$MAX_WIDTH" ]; then
      sips --resampleWidth "$MAX_WIDTH" "$input_for_sips" --out "$resized" >/dev/null
    else
      cp "$input_for_sips" "$resized"
    fi

    # Paso 3: convertir a WebP
    cwebp -q "$WEBP_QUALITY" "$resized" -o "$webp_out" >/dev/null 2>&1

    # Limpieza intermedios
    [ -n "$intermediate" ] && rm -f "$intermediate"
    rm -f "$resized"

    PROCESADAS+=("$cat/$base")
    TOTAL=$((TOTAL+1))
  done
done

# ============================================================================
# 3. SIN NADA QUE HACER
# ============================================================================
if [ "$TOTAL" -eq 0 ]; then
  echo "✓ No hay fotos nuevas. Nada que hacer."
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  echo "✓ Dry-run: $TOTAL fotos serían procesadas."
  exit 0
fi

echo "✓ $TOTAL fotos procesadas."

# ============================================================================
# 4. MOVER ORIGINALES A _procesadas/ EN EL NAS
# ============================================================================
if [ "$MOVE_PROCESADAS" -eq 1 ]; then
  echo "▶ Moviendo originales a _procesadas/ en NAS..."
  for cat in "${CATEGORIAS[@]}"; do
    cat_tmp="$TMP_DIR/$cat"
    [ -d "$cat_tmp" ] || continue

    to_move=()
    for src in "$cat_tmp"/*; do
      [ -f "$src" ] || continue
      base="$(basename "$src")"
      name_no_ext="${base%.*}"
      # Solo mover si su .webp existe (o sea, la procesamos con éxito)
      if [ -f "$IMG_DIR/$cat/${name_no_ext}.webp" ]; then
        to_move+=("$base")
      fi
    done

    if [ "${#to_move[@]}" -gt 0 ]; then
      ssh "$NAS_HOST" "mkdir -p '$NAS_SRC/_procesadas/$cat'"
      for base in "${to_move[@]}"; do
        ssh "$NAS_HOST" "mv '$NAS_SRC/$cat/$base' '$NAS_SRC/_procesadas/$cat/$base'" 2>/dev/null || true
      done
    fi
  done
fi

# ============================================================================
# 5. REGENERAR catalog.ts
# ============================================================================
echo "▶ Regenerando src/data/catalog.ts..."

{
  echo "// Auto-generado por scripts/publicar-artemisa.sh — no editar a mano."
  echo "// Última generación: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo "export const catalogImages = {"
  for cat in "${CATEGORIAS[@]}"; do
    cat_web="$IMG_DIR/$cat"
    [ -d "$cat_web" ] || continue

    # clave TypeScript: sin guiones (flor-seca → florseca)
    key="$(echo "$cat" | tr -d '-')"

    echo "  $key: ["
    # ordenar alfabéticamente para orden determinista
    find "$cat_web" -maxdepth 1 -type f -name "*.webp" | sort | while read -r f; do
      echo "    '/images/$cat/$(basename "$f")',"
    done
    echo "  ],"
  done
  echo "};"
} > "$CATALOG_TS"

# ============================================================================
# 6. GIT COMMIT + PUSH
# ============================================================================
cd "$REPO_DIR"
git add public/images src/data/catalog.ts

if git diff --cached --quiet; then
  echo "⚠ Sin cambios que commitear (git ya estaba limpio)."
  exit 0
fi

# Construir mensaje de commit
CAT_SUMMARY=""
declare -A CAT_COUNT
for p in "${PROCESADAS[@]}"; do
  c="${p%%/*}"
  CAT_COUNT[$c]=$((${CAT_COUNT[$c]:-0}+1))
done
for c in "${!CAT_COUNT[@]}"; do
  CAT_SUMMARY="$CAT_SUMMARY ${CAT_COUNT[$c]} $c,"
done
CAT_SUMMARY="${CAT_SUMMARY%,}"

MSG="Nuevas fotos ($TOTAL):${CAT_SUMMARY}"
git commit -m "$MSG"

if [ "$DO_PUSH" -eq 1 ]; then
  echo "▶ Push a GitHub..."
  git push
  echo ""
  echo "✓ HECHO. Vercel iniciará el deploy automáticamente en unos segundos."
  echo "  Panel Vercel: https://vercel.com/dashboard"
  echo "  Web:          https://artemisafloristas.com"
else
  echo "✓ Commit local hecho. Push pendiente:"
  echo "    cd '$REPO_DIR' && git push"
fi
