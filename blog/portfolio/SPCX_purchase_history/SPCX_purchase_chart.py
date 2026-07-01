import pandas as pd
import matplotlib.pyplot as plt
import yfinance as yf
import os
from datetime import datetime 

# --- Input Data ---
purchase_dates = [
        "12/06/26", "29/06/26"
]
purchase_prices = [
       135.00, 157.40 
]

purchase_df = pd.DataFrame({
    'Date': pd.to_datetime(purchase_dates, format="%d/%m/%y"),
    'Price': purchase_prices
})

# Download SPCX data
start_date = purchase_df['Date'].min() - pd.Timedelta(days=30)
end_date = purchase_df['Date'].max() + pd.Timedelta(days=300)
spcx = yf.download("SPCX", start=start_date, end=end_date)

spcx.index = pd.to_datetime(spcx.index)

valid_purchases = purchase_df[purchase_df['Date'].isin(spcx.index)]

# Plot
plt.figure(figsize=(14, 7))
plt.plot(spcx['Close'], label='SPCX Closing Price', color='blue')
plt.scatter(valid_purchases['Date'], valid_purchases['Price'], color='red', label='Purchase', zorder=5)


plt.title(str('SPCX Stock Price with Purchases (last updated:'+str(datetime.now().strftime("%d %B %Y"))+")"))
plt.xlabel('Date')
plt.ylabel('Price (USD)')
plt.legend()
plt.grid(True)
plt.tight_layout()

# --- Save Instead of Show ---
default_path = "blog/portfolio/SPCX_purchase_history/SPCX_purchases.png"
print(f"\nDefault save location: {default_path}")
use_default = input("Save to default location? (y/n): ").strip().lower()

save_path = default_path

plt.savefig(save_path, dpi=300)
print(f"Chart saved to: {save_path}")

