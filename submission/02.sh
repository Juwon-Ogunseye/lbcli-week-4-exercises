#!/bin/bash

# Define variables for the txid, vouts, recipient address, and amount
TXID="23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16"
VOUT0=0
VOUT1=1
RECIPIENT="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
AMOUNT=0.2
LOCKTIME=2041

# Create the raw transaction using the provided inputs
RAW_TX=$(bitcoin-cli -regtest createrawtransaction \
  "[{\"txid\":\"$TXID\", \"vout\":$VOUT0}, {\"txid\":\"$TXID\", \"vout\":$VOUT1}]" \
  "{\"$RECIPIENT\":$AMOUNT}" \
  $LOCKTIME)

# Output the raw transaction
echo "Raw Transaction: $RAW_TX"
