#Updates the chart, then the average price numbers. 
#The average price number script will ask if you want to upload straight away.


set -euo pipefail

rm blog/portfolio/TSLA_purchase_history/TSLA_purchases.png
../code/bashScripts/updateMarksch.sh
#git rm blog/portfolio/TSLA_purchase_history/TSLA_purchases.png
#git rm --cached blog/portfolio/tsla_purchase_history/tsla_purchases.png
python3 blog/portfolio/TSLA_purchase_history/date_plot_chart3.py
blog/portfolio/update_averages.sh
