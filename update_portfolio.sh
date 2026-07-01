#Updates the chart, then the average price numbers. 
#The average price number script will ask if you want to upload straight away.


set -euo pipefail

cd ~/Documents/marksch

rm blog/portfolio/TSLA_purchase_history/TSLA_purchases.png
rm blog/portfolio/SPCX_purchase_history/SPCX_purchases.png
rm blog/portfolio/MSTR_purchase_history/MSTR_purchases.png
../code/bashScripts/updateMarksch.sh
#git rm blog/portfolio/TSLA_purchase_history/TSLA_purchases.png
#git rm --cached blog/portfolio/tsla_purchase_history/tsla_purchases.png
python3 blog/portfolio/TSLA_purchase_history/TSLA_purchase_chart.py
python3 blog/portfolio/SPCX_purchase_history/SPCX_purchase_chart.py
python3 blog/portfolio/MSTR_purchase_history/MSTR_purchase_chart.py
blog/portfolio/update_percentages.sh
blog/portfolio/update_averages.sh
