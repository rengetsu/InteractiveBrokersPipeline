from ib_insync import *
import pandas as pd

ib = IB()
ib.connect('127.0.0.1', 7497, clientId=2)

# Defining here Forex contract manually
contract = Contract()
contract.symbol = 'EUR'
contract.secType = 'CASH'
contract.currency = 'USD'
contract.exchange = 'IDEALPRO'

ib.qualifyContracts(contract)

print("Requesting historical data (5-minute bars for 1 day)...")

bars = ib.reqHistoricalData(
    contract,
    endDateTime='',
    durationStr='1 D',
    barSizeSetting='5 mins',
    whatToShow='MIDPOINT',
    useRTH=False,
    formatDate=1
)

ib.disconnect()

# Verify results
if not bars:
    print("No historical bars returned")
else:
    df = util.df(bars)
    df['equity'] = 'EURUSD'
    df = df.rename(columns={'time': 'date'})
    df = df[['date', 'open', 'high', 'low', 'close', 'equity']]
    df.to_csv('realtime_forex_input.csv', index=False)
    print("✅ Saved: realtime_forex_input.csv")
