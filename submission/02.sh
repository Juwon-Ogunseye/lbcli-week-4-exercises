#!/bin/bash

# Define variables
TXID="c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef7725"
VOUT=0
AMOUNT=20000000  # 20,000,000 satoshis
RECEIVER="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
CURRENT_BLOCK=25
LOCKTIME=$(($CURRENT_BLOCK + 20160))  # Adding 2 weeks (20160 blocks for Bitcoin's 10 minute block time)

# Get the previous UTXO (Unspent Transaction Output)
UTXO=$(bitcoin-cli getrawtransaction $TXID true)

# Get the amount from the UTXO
VALUE=$(echo $UTXO | jq '.vout['$VOUT'].value')

# Create the raw transaction
RAW_TX=$(bitcoin-cli createrawtransaction '[{"txid": "'$TXID'", "vout": '$VOUT'}]' '[{"'$RECEIVER'": '$AMOUNT'}]')

# Set the locktime for the transaction
LOCKTIME_TX=$(bitcoin-cli decoderawtransaction $RAW_TX | jq --arg locktime "$LOCKTIME" '.locktime = ($locktime | tonumber)')

# Finalize the raw transaction with locktime
FINAL_RAW_TX=$(bitcoin-cli signrawtransactionwithwallet $LOCKTIME_TX)

# Output the raw transaction
echo "Raw Transaction: $FINAL_RAW_TX"
