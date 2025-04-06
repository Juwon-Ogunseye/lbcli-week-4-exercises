#!/bin/bash

# Define variables
RAW_TX="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Extract the TXID (first 64 characters of the raw transaction)
TXID=$(echo $RAW_TX | cut -c 3-66)

# Other variables
VOUT=0
AMOUNT=20000000  # 20,000,000 satoshis
RECEIVER="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
CURRENT_BLOCK=25
LOCKTIME=$(($CURRENT_BLOCK + 20160))  # Adding 2 weeks (20160 blocks for Bitcoin's 10 minute block time)

# Get the previous UTXO (Unspent Transaction Output)
UTXO=$(bitcoin-cli -regtest getrawtransaction $TXID true)

# Get the amount from the UTXO
VALUE=$(echo $UTXO | jq '.vout['$VOUT'].value')

# Create the raw transaction
RAW_TX=$(bitcoin-cli -regtest createrawtransaction '[{"txid": "'$TXID'", "vout": '$VOUT'}]' '[{"'$RECEIVER'": '$AMOUNT'}]')

# Set the locktime for the transaction
LOCKTIME_TX=$(bitcoin-cli -regtest decoderawtransaction $RAW_TX | jq --arg locktime "$LOCKTIME" '.locktime = ($locktime | tonumber)')

# Finalize the raw transaction with locktime
FINAL_RAW_TX=$(bitcoin-cli -regtest signrawtransactionwithwallet $LOCKTIME_TX)

# Output the raw transaction
echo "Raw Transaction: $FINAL_RAW_TX"
