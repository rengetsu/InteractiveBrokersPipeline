from ib_insync import *
from pprint import pprint  # Pretty print
ib = IB()
ib.connect('127.0.0.1', 7497, clientId=1)
summary = ib.accountSummary()
pprint(summary)
ib.disconnect()
