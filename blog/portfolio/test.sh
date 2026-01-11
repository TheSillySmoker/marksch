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
  [[ "$cleaned" =~ ^[0-9]+([.][0-9]+)?$ ]] || { echo "Invalid price: $line"; exit 1; }
  prices+=("$cleaned")
done

[[ "${#prices[@]}" -eq 5 ]] || { echo "Expected 5 prices"; exit 1; }

TSLA="${prices[0]}"
MSTR="${prices[1]}"
ARKG="${prices[2]}"
CRSP="${prices[3]}"
VAS="${prices[4]}"

echo
echo "Paste 5 percentages (TSLA, MSTR, ARKG, CRSP, VAS), one per line."
echo "Ctrl-D when done."
echo

pcts=()
while IFS= read -r line; do
  cleaned="$(printf '%s' "$line" | tr -d '\r' | sed -E 's/[[:space:]]+//g; s/%$//')"
  [[ -z "$cleaned" ]] && continue
  [[ "$cleaned" =~ ^-?[0-9]+([.][0-9]+)?$ ]] || { echo "Invalid %: $line"; exit 1; }
  pcts+=("$cleaned")
done

[[ "${#pcts[@]}" -eq 5 ]] || { echo "Expected 5 percentages"; exit 1; }

TSLA_P="${pcts[0]}"
MSTR_P="${pcts[1]}"
ARKG_P="${pcts[2]}"
CRSP_P="${pcts[3]}"
VAS_P="${pcts[4]}"

TODAY="$(date '+%d %B %Y')"

cp -a "$HTML_FILE" "$HTML_FILE.bak"

# Build one Vim script
VIM_SCRIPT=$(cat <<EOF
%s/^\(\s*TSLA:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$TSLA/e
%s/^\(\s*MSTR:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$MSTR/e
%s/^\(\s*ARKG:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$ARKG/e
%s/^\(\s*CRSP:.*Average price (USD): \$\)\zs[0-9.][0-9.]*/$CRSP/e
%s/^\(\s*VAS:.*Average price (AUD): \$\)\zs[0-9.][0-9.]*/$VAS/e

%s/^\(\s*TSLA:.*(\)\zs-\\?[0-9.][0-9.]*\ze%)/$TSLA_P/e
%s/^\(\s*MSTR:.*(\)\zs-\\?[0-9.][0-9.]*\ze%)/$MSTR_P/e
%s/^\(\s*ARKG:.*(\)\zs-\\?[0-9.][0-9.]*\ze%)/$ARKG_P/e
%s/^\(\s*CRSP:.*(\)\zs-\\?[0-9.][0-9.]*\ze%)/$CRSP_P/e
%s/^\(\s*VAS:.*(\)\zs-\\?[0-9.][0-9.]*\ze%)/$VAS_P/e

%s/^\(.*Holdings as of \).*/\1$TODAY/e
wq
EOF
)
echo "failpoint?"
tmp_vim="$(mktemp)"
# (optional) strip any CR chars just in case
printf '%s' "$VIM_SCRIPT" | tr -d '\r' > "$tmp_vim"

vim -Es "$HTML_FILE" -S "$tmp_vim"
rm -f "$tmp_vim"

echo "failpoint22?"

echo "Prices and percentages updated"
echo "Date set to $TODAY"
echo "Backup saved as $HTML_FILE.bak"

printf "\nWould you like to push the changes to github and have them pulled down by the vps? (y/n)"

read push
if [ "$push" = "y" ];then
	bash /home/mark/Documents/code/bashScripts/updateMarksch.sh
else
	echo "Okay, we won't push it for you."
fi
