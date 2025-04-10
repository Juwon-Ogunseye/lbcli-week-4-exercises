#!/bin/bash

set -e
set -x

#!/bin/bash

# === Configuration ===
TXID="72efbd235f00d1d92c77e3e4b2a5f6d9954547d0865f8d695eecbbde8e92b0c8"
VOUT=0
AMOUNT=0.2
RECEIVER="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
LOCKTIME=2041
# === Create Raw Transaction ===
RAW_TX=$(bitcoin-cli -testnet createrawtransaction \
  "[{\"txid\":\"$TXID\",\"vout\":$VOUT}]" \
  "{\"$RECEIVER\":$AMOUNT}" \
  $LOCKTIME)
# === Output ===
echo "Raw unsigned transaction (locked until block $LOCKTIME):"
echo "$RAW_TX"
