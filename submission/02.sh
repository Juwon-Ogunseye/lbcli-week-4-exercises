#!/bin/bash

# Provided raw transaction from the assignment
raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Decode the raw transaction using bitcoin-cli in regtest mode
decoded_tx=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx")

# Extract the txid and vout index from the decoded transaction using jq
txid=$(echo "$decoded_tx" | jq -r '.txid')
vout_index=$(echo "$decoded_tx" | jq -r '.vout[0].n')

# Output the txid and vout_index for debugging purposes
echo "Transaction ID (txid): $txid"
echo "Vout Index: $vout_index"

# Set the output address and amount (20,000,000 satoshis)
output_address="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount=20000000  # 20,000,000 satoshis

# Set the locktime for 2 weeks (in Unix timestamp format)
current_time=$(date +%s)
locktime=$((current_time + 1209600))  # 1209600 seconds = 2 weeks

# Create the new raw transaction using bitcoin-cli with locktime
raw_tx_new=$(bitcoin-cli -regtest createrawtransaction \
  "[{\"txid\":\"$txid\",\"vout\":$vout_index}]" \
  "[{\"$output_address\":$amount}]")

# Set the locktime (timelock) in the raw transaction
raw_tx_timelocked=$(bitcoin-cli -regtest createrawtransaction \
  "[{\"txid\":\"$txid\",\"vout\":$vout_index}]" \
  "[{\"$output_address\":$amount}]" \
  "$locktime")

# Sign the transaction
signed_tx=$(bitcoin-cli -regtest signrawtransactionwithkey "$raw_tx_timelocked" \
  "[\"$(bitcoin-cli -regtest dumpprivkey <your_bitcoin_address>)]")

# Extract the hex-encoded signed transaction
signed_tx_hex=$(echo "$signed_tx" | jq -r '.hex')

# Output the signed transaction hex
echo "Signed Transaction Hex: $signed_tx_hex"

# Send the signed transaction
txid_sent=$(bitcoin-cli -regtest sendrawtransaction "$signed_tx_hex")

# Output the txid of the sent transaction
echo "Transaction successfully sent! Transaction ID: $txid_sent"
