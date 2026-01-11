#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="portfolio.html"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "Error: file not found: $HTML_FILE" >&2
  exit 1
fi

echo "Paste 5 prices (TSLA, MSTR, ARKG, CRSP, VAS), one per line."
echo "When done, press Ctrl-D."
echo

prices=()
while IFS= read -r line; do
  cleaned="$(printf '%s' "$line" | tr -d '\r' | sed -E 's/[[:space:]]+//g; s/^\$//')"
  [[ -z "$cleaned" ]] && continue

  if [[ ! "$cleaned" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: invalid price line: '$line'" >&2
    exit 1
  fi

  prices+=("$cleaned")
done

if [[ "${#prices[@]}" -ne 5 ]]; then
  echo "Error: expected 5 prices, got ${#prices[@]}." >&2
  exit 1
fi

TSLA="${prices[0]}"
MSTR="${prices[1]}"
ARKG="${prices[2]}"
CRSP="${prices[3]}"
VAS="${prices[4]}"

TODAY="$(date '+%d %B %Y')"

# Backup once
cp -a "$HTML_FILE" "$HTML_FILE.bak"

# ---- VIM RUN #1: prices + date ----
if ! vim -Es "$HTML_FILE" \
  -c "%s/^\(\s*TSLA:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$TSLA/e" \
  -c "%s/^\(\s*MSTR:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$MSTR/e" \
  -c "%s/^\(\s*ARKG:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$ARKG/e" \
  -c "%s/^\(\s*CRSP:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$CRSP/e" \
  -c "%s/^\(\s*VAS:.*Average price (AUD): \$\)\zs[0-9.][0-9.]*/$VAS/e" \
  -c "%s/^\(.*Holdings as of \).*/\1$TODAY/e" \
  -c "wq"
then
  echo "Error: vim failed updating prices/date. Backup kept at: $HTML_FILE.bak" >&2
  exit 1
fi

echo
echo "Paste 5 percentages (TSLA, MSTR, ARKG, CRSP, VAS), one per line."
echo "You can include or omit the % sign. Example: 12.34% or 12.34"
echo "When done, press Ctrl-D."
echo

pcts=()
while IFS= read -r line; do
  cleaned="$(printf '%s' "$line" | tr -d '\r' | sed -E 's/[[:space:]]+//g; s/%$//')"
  [[ -z "$cleaned" ]] && continue

  if [[ ! "$cleaned" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: invalid percentage line: '$line'" >&2
    exit 1
  fi

  pcts+=("$cleaned")
done

if [[ "${#pcts[@]}" -ne 5 ]]; then
  echo "Error: expected 5 percentages, got ${#pcts[@]}." >&2
  exit 1
fi

TSLA_P="${pcts[0]}"
MSTR_P="${pcts[1]}"
ARKG_P="${pcts[2]}"
CRSP_P="${pcts[3]}"
VAS_P="${pcts[4]}"

# ---- VIM RUN #2: percentages ----
# Assumes each ticker line contains something like "(12.34%)" somewhere on the same line.
if ! vim -Es "$HTML_FILE" \
  -c "%s/^\(\s*TSLA:.*(\)\zs-\?[0-9.][0-9.]*\ze%)/$TSLA_P/e" \
  -c "%s/^\(\s*MSTR:.*(\)\zs-\?[0-9.][0-9.]*\ze%)/$MSTR_P/e" \
  -c "%s/^\(\s*ARKG:.*(\)\zs-\?[0-9.][0-9.]*\ze%)/$ARKG_P/e" \
  -c "%s/^\(\s*CRSP:.*(\)\zs-\?[0-9.][0-9.]*\ze%)/$CRSP_P/e" \
  -c "%s/^\(\s*VAS:.*(\)\zs-\?[0-9.][0-9.]*\ze%)/$VAS_P/e" \
  -c "wq"
then
  echo "Error: vim failed updating percentages. Backup kept at: $HTML_FILE.bak" >&2
  exit 1
fi

echo "Prices and percentages updated."
echo "Date set to $TODAY"
echo "Backup saved as $HTML_FILE.bak"

printf "\nWould you like to push the changes to github and have them pulled down by the vps? (y/n)"

read push
if [ "$push" = "y" ];then
	bash /home/mark/Documents/code/bashScripts/updateMarksch.sh
else
	echo "Okay, we won't push it for you."
fi
