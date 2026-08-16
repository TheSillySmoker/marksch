import pandas as pd
import matplotlib.pyplot as plt
import yfinance as yf
import os
from datetime import datetime 

# --- Input Data ---
purchase_dates = [
        "03/12/25", "18/12/25", "06/01/26", "12/01/26", "13/01/26", "17/08/26"
]
purchase_prices = [
    185.46,
    163.35,
    161.50,
    158.79,
    163.97,
    94.07
]

purchase_df = pd.DataFrame({
    'Date': pd.to_datetime(purchase_dates, format="%d/%m/%y"),
    'Price': purchase_prices
})

# Download MSTR data
start_date = purchase_df['Date'].min() - pd.Timedelta(days=30)
end_date = purchase_df['Date'].max() + pd.Timedelta(days=300)
mstr = yf.download("MSTR", start=start_date, end=end_date)

mstr.index = pd.to_datetime(mstr.index)

valid_purchases = purchase_df[purchase_df['Date'].isin(mstr.index)]

# Plot
plt.figure(figsize=(14, 7))
plt.plot(mstr['Close'], label='MSTR Closing Price', color='blue')
plt.scatter(valid_purchases['Date'], valid_purchases['Price'], color='red', label='Purchase', zorder=5)

plt.title(str('MSTR Stock Price with Purchases (last updated:'+str(datetime.now().strftime("%d %B %Y"))+")"))
plt.xlabel('Date')
plt.ylabel('Price (USD)')
plt.legend()
plt.grid(True)
plt.tight_layout()

# --- Save Instead of Show ---
default_path = "blog/portfolio/MSTR_purchase_history/MSTR_purchases.png"
print(f"\nDefault save location: {default_path}")

save_path = default_path

plt.savefig(save_path, dpi=300)
print(f"Chart saved to: {save_path}")

