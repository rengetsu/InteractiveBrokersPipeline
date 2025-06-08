from datetime import datetime
import pandas as pd

# Load positions
df = pd.read_csv('../dt_positions.csv')
df = df[df['pos_type'] == 'position']

logs = []

for index, row in df.iterrows():
    print(f"Simulating BUY at: {row['date_start']}")
    logs.append({
        'side': 'BUY',
        'time': row['date_start'],
        'price': 1.0875,  # last close/sample price
        'commission': 0.00
    })

    print(f"Holding...")

    print(f"Simulating SELL at: {row['date_end']}")
    logs.append({
        'side': 'SELL',
        'time': row['date_end'],
        'price': 1.0882,  # next close/sample price
        'commission': 0.00
    })

log_df = pd.DataFrame(logs)
log_df.to_csv('execution_log.csv', index=False)
print("✅ Simulated execution log saved.")
