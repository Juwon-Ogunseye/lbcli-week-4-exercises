#!/bin/bash

# Define variables for the txid, vouts, recipient address, and amount
TXID="23c19f37d4e92e9a115aab86e4edc1b92a51add4e0ed0034bb166314dde50e16"
VOUT0=0
VOUT1=1
RECIPIENT="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
AMOUNT=0.2
LOCKTIME=2041

# Step 1: Create the raw transaction using the provided inputs
RAW_TX=$(bitcoin-cli -regtest createrawtransaction \
  "[{\"txid\":\"$TXID\", \"vout\":$VOUT0}, {\"txid\":\"$TXID\", \"vout\":$VOUT1}]" \
  "{\"$RECIPIENT\":$AMOUNT}" \
  $LOCKTIME)

# Step 2: Decode the raw transaction
DECODED_TX=$(bitcoin-cli -regtest decoderawtransaction "$RAW_TX")

# Step 3: Replace sequence feffffff with fdffffff for both inputs (RBF enabled)
UPDATED_TX=$(echo "$DECODED_TX" | jq '.vin |= map(.sequence = 4294967294)')

# Step 4: Re-encode the modified transaction back to raw hex
MODIFIED_RAW_TX=$(echo "$UPDATED_TX" | jq -r '.hex')

# Step 5: Output the modified raw transaction
echo "Modified Raw Transaction: $MODIFIED_RAW_TX"

# Step 6: Optionally, you can sign and send the transaction
# SIGNED_TX=$(bitcoin-cli -regtest signrawtransactionwithwallet "$MODIFIED_RAW_TX")
# echo "Signed Transaction: $SIGNED_TX"
