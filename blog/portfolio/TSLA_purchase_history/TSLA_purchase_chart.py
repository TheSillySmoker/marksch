import pandas as pd
import matplotlib.pyplot as plt
import yfinance as yf
import os
from datetime import datetime 

# --- Input Data ---
purchase_dates = [
    "04/09/20", "04/09/20", "08/09/20", "10/09/20", "19/11/20", "25/11/20", "09/03/21", "30/04/21",
    "08/10/21", "15/10/21", "04/11/21", "09/11/21", "11/11/21", "11/11/21", "16/11/21", "18/11/21",
    "18/11/21", "30/11/21", "07/12/21", "15/12/21", "16/12/21", "18/12/21", "04/01/22", "01/04/22",
    "12/01/22", "21/01/22", "21/01/22", "21/01/22", "28/01/22", "01/02/22", "08/03/22", "16/03/22",
    "30/03/22", "19/04/22", "25/04/22", "27/04/22", "11/05/22", "20/05/22", "20/05/22", "14/07/22",
    "15/08/22", "17/08/22", "22/08/22", "12/09/22", "21/09/22", "19/10/22", "11/11/22", "16/11/22",
    "19/12/22", "10/01/23", "12/01/23", "18/01/23", "09/02/23", "02/03/23", "20/03/23", "05/04/23",
    "03/05/23", "16/05/23", "19/06/23", "28/06/23", "12/07/23", "02/08/23", "09/08/23", "22/08/23",
    "26/09/23", "09/10/23", "20/10/23", "22/11/23", "27/11/23", "04/12/23", "08/12/23", "13/12/23",
    "21/12/23", "27/12/23", "04/01/24", "12/01/24", "12/01/24", "16/01/24", "19/01/24", "23/01/24",
    "29/01/24", "26/02/24", "20/03/24", "20/03/24", "25/03/24", "03/04/24", "26/04/24", "30/04/24",
    "03/05/24", "13/05/24", "24/05/24", "30/05/24", "03/06/24", "26/06/24", "19/07/24", "26/07/24",
    "09/08/24", "22/08/24", "10/09/24", "18/09/24", "08/10/24", "14/10/24", "28/02/25", "18/03/25",
    "24/03/25", "14/04/25", "27/05/25", "08/07/25", "09/09/25", "21/11/25", "07/04/26"
]
purchase_prices = [
    136.60, 137.28, 117.90, 118.52, 148.55, 182.22, 189.76, 225.15,
    261.67, 272.13, 393.18, 390.63, 338.83, 336.68, 337.05, 356.08,
    353.33, 367.00, 333.33, 313.99, 317.25, 305.99, 381.53, 357.15,
    352.78, 336.60, 334.95, 333.33, 280.00, 289.84, 285.19, 255.00,
    369.50, 335.20, 329.33, 298.62, 264.60, 235.00, 238.87, 226.49,
    297.97, 303.88, 292.14, 300.59, 307.29, 221.99, 176.00, 194.55,
    157.33, 119.19, 121.77, 125.70, 202.42, 191.65, 177.64, 194.00,
    160.82, 166.93, 259.22, 251.00, 271.71, 260.00, 250.87, 236.59,
    245.98, 255.91, 218.12, 241.12, 235.47, 238.83, 241.97, 240.00,
    253.00, 253.00, 240.00, 234.00, 225.00, 215.44, 211.75, 208.34,
    183.49, 191.31, 172.00, 170.34, 168.84, 166.25, 172.94, 189.17,
    182.00, 169.00, 174.00, 174.97, 178.36, 187.64, 250.00, 225.00,
    200.70, 222.99, 217.00, 228.65, 241.00, 218.00, 282.60, 244.27,
    256.21, 257.70, 347.29, 296.78, 331.97, 392.77, 362.00
]

sale_date = pd.to_datetime("15/01/21", format="%d/%m/%y")
sale_price = 284.75

purchase_df = pd.DataFrame({
    'Date': pd.to_datetime(purchase_dates, format="%d/%m/%y"),
    'Price': purchase_prices
})

# Download TSLA data
start_date = min(purchase_df['Date'].min(), sale_date) - pd.Timedelta(days=30)
end_date = max(purchase_df['Date'].max(), sale_date) + pd.Timedelta(days=300)
tsla = yf.download("TSLA", start=start_date, end=end_date)

tsla.index = pd.to_datetime(tsla.index)

valid_purchases = purchase_df[purchase_df['Date'].isin(tsla.index)]
sale_is_valid = sale_date in tsla.index

# Plot
plt.figure(figsize=(14, 7))
plt.plot(tsla['Close'], label='TSLA Closing Price', color='blue')
plt.scatter(valid_purchases['Date'], valid_purchases['Price'], color='red', label='Purchase', zorder=5)
if sale_is_valid:
    plt.scatter(sale_date, sale_price, color='palevioletred', label='Sale', zorder=5)

plt.title(str('TSLA Stock Price with Purchases and Sale (last updated:'+str(datetime.now().strftime("%d %B %Y"))+")"))
plt.xlabel('Date')
plt.ylabel('Price (USD)')
plt.legend()
plt.grid(True)
plt.tight_layout()

# --- Save Instead of Show ---
default_path = "blog/portfolio/TSLA_purchase_history/TSLA_purchases.png"
print(f"\nDefault save location: {default_path}")
use_default = input("Save to default location? (y/n): ").strip().lower()

if use_default == "y":
    save_path = default_path
else:
    save_path = input("Enter full save path (e.g. /home/user/chart.png): ").strip()

plt.savefig(save_path, dpi=300)
print(f"Chart saved to: {save_path}")

