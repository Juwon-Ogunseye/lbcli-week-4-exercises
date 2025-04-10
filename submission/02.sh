#!/bin/bash

# UTXO from the transaction provided
TXID="72efbd235f00d1d92c77e3e4b2a5f6d9954547d0865f8d695eecbbde8e92b0c8"
VOUT=0

# Output address and amount (20,000,000 satoshis)
RECEIVER="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
AMOUNT="0.2"  # in BTC (which is 20,000,000 satoshis)

# Locktime set for 2 weeks from current block height (25)
LOCKTIME=2041

# Create raw transaction using bitcoin-cli
RAW_TX=$(bitcoin-cli -regtest createrawtransaction \
'[{"txid":"'"$TXID"'","vout":'"$VOUT"'}]' \
'{"'"$RECEIVER"'":'"$AMOUNT"'}' $LOCKTIME)

# Output the raw transaction
echo "Raw Transaction: $RAW_TX"
