#!/usr/bin/env bash
# Percent updater: read percentages from Calc (.ods) by converting to .xlsx once, then update HTML
set -euo pipefail

# ------------------ EDIT THESE ------------------
HTML_FILE="portfolio.html"

ODS_FILE="/run/user/1000/gvfs/smb-share:server=marks-macbook-air.local,share=sambashare/open_mark/open_marks_portfolio_mac.ods"
SHEET_NAME="Insights"   # must match exactly (case-sensitive)

# Cells in the sheet (set these to wherever your % live)
CELL_TSLA_P="D21"
CELL_MSTR_P="D22"
CELL_ARKG_P="D23"
CELL_CRSP_P="D24"
CELL_VAS_P="D25"
# ------------------------------------------------

die() { echo "Error: $*" >&2; exit 1; }

[[ -f "$HTML_FILE" ]] || die "HTML file not found: $HTML_FILE"
[[ -f "$ODS_FILE"   ]] || die "Spreadsheet not found: $ODS_FILE"

# LibreOffice binary (Debian may provide 'libreoffice' and/or 'soffice')
LO_BIN=""
if command -v libreoffice >/dev/null 2>&1; then
  LO_BIN="libreoffice"
elif command -v soffice >/dev/null 2>&1; then
  LO_BIN="soffice"
else
  die "LibreOffice not found. Install with: sudo apt install libreoffice"
fi

python3 -c "import openpyxl" >/dev/null 2>&1 \
  || die "python3-openpyxl not found. Install with: sudo apt install python3-openpyxl"

tmpdir="$(mktemp -d)"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT

# Convert ODS -> XLSX (one-time snapshot per run)
"$LO_BIN" --headless --nologo --nolockcheck --nodefault --norestore \
  --convert-to xlsx --outdir "$tmpdir" "$ODS_FILE" >/dev/null 2>&1 \
  || die "LibreOffice failed converting ODS to XLSX."

# Find the converted xlsx
xlsx="$(ls -1 "$tmpdir"/*.xlsx 2>/dev/null | head -n 1 || true)"
[[ -n "$xlsx" && -f "$xlsx" ]] || die "Could not locate converted XLSX in $tmpdir"

# Read the 5 cells from the converted XLSX
mapfile -t pcts < <(
python3 - "$xlsx" "$SHEET_NAME" \
  "$CELL_TSLA_P" "$CELL_MSTR_P" "$CELL_ARKG_P" "$CELL_CRSP_P" "$CELL_VAS_P" <<'PY'
import sys
from openpyxl import load_workbook

xlsx_path = sys.argv[1]
sheet_name = sys.argv[2]
cells = sys.argv[3:]

wb = load_workbook(xlsx_path, data_only=True, read_only=True)
if sheet_name not in wb.sheetnames:
    raise SystemExit(f"Error: sheet not found: {sheet_name}. Available: {', '.join(wb.sheetnames)}")

ws = wb[sheet_name]

def to_percent_text(v):
    # Returns a numeric string like "98.30" (no % sign)
    if v is None:
        return ""

    # If it is numeric, handle fraction-vs-whole:
    if isinstance(v, (int, float)):
        x = float(v)
        # Heuristic: if between 0 and 1, treat as a fraction (e.g. 0.983 => 98.3)
        if 0 < x <= 1:
            x *= 100.0
        return str(x)

    # If it is a string, strip whitespace and optional trailing %
    s = str(v).strip().replace(" ", "")
    if s.endswith("%"):
        s = s[:-1]
    # If string parses as float and looks like fraction, convert
    try:
        x = float(s)
        if 0 < x <= 1:
            x *= 100.0
        return str(x)
    except ValueError:
        return s  # will fail validation later

for c in cells:
    print(to_percent_text(ws[c].value))
PY
)

[[ "${#pcts[@]}" -eq 5 ]] || die "Expected 5 percentage values, got ${#pcts[@]}."

# Validate numeric
for i in "${!pcts[@]}"; do
  v="${pcts[$i]}"
  [[ -n "$v" ]] || die "Empty cell value at index $i (check sheet/cell refs)."
  [[ "$v" =~ ^[0-9]+([.][0-9]+)?$ ]] || die "Non-numeric percentage value '$v' at index $i."
done

# Round to 2 decimals (no % sign)
TSLA_P="$(printf "%.2f" "${pcts[0]}")"
MSTR_P="$(printf "%.2f" "${pcts[1]}")"
ARKG_P="$(printf "%.2f" "${pcts[2]}")"
CRSP_P="$(printf "%.2f" "${pcts[3]}")"
VAS_P="$(printf "%.2f" "${pcts[4]}")"

# Backup
cp -a "$HTML_FILE" "$HTML_FILE.pct.bak"

# Updates the number after "TICKER:" and before the "%" sign.
if ! vim -Es "$HTML_FILE" \
  -c "%s/^\(\s*TSLA:\s*\)\zs[0-9.][0-9.]*/$TSLA_P/e" \
  -c "%s/^\(\s*MSTR:\s*\)\zs[0-9.][0-9.]*/$MSTR_P/e" \
  -c "%s/^\(\s*ARKG:\s*\)\zs[0-9.][0-9.]*/$ARKG_P/e" \
  -c "%s/^\(\s*CRSP:\s*\)\zs[0-9.][0-9.]*/$CRSP_P/e" \
  -c "%s/^\(\s*VAS:\s*\)\zs[0-9.][0-9.]*/$VAS_P/e" \
  -c "wq"
then
  die "vim failed to update the file. Backup kept at: $HTML_FILE.pct.bak"
fi

echo "Percentages updated from ODS snapshot ($ODS_FILE) sheet '$SHEET_NAME'."
echo "TSLA=$TSLA_P%  MSTR=$MSTR_P%  ARKG=$ARKG_P%  CRSP=$CRSP_P%  VAS=$VAS_P%"
echo "Backup saved as $HTML_FILE.pct.bak"

