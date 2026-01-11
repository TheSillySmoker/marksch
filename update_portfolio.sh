#Updates the chart, then the average price numbers. 
#The average price number script will ask if you want to upload straight away.


set -euo pipefail

python3 blog/portfolio/TSLA_purchase_history/date_plot_chart3.py
blog/portfolio/update_averages.sh
