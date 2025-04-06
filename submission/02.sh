#!/bin/bash

# Current block height (provided in the assignment)
current_block=25

# Calculate the number of blocks in two weeks
# 2 weeks = 14 days = 14 * 24 hours * 6 blocks/hour = 2016 blocks
blocks_in_two_weeks=2016

# Calculate the locktime (current block + blocks in two weeks)
locktime=$((current_block + blocks_in_two_weeks))

# UTXO details (from the assignment)
txid="c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef7725"
vout=0

# Recipient address and amount (20,000,000 satoshis = 0.2 BTC)
recipient_address="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount="0.2"

# Create raw transaction using bitcoin-cli in regtest mode
rawtxhex=$(bitcoin-cli -regtest -named createrawtransaction \
  inputs="[\"{\\\"txid\\\": \\\"$txid\\\", \\\"vout\\\": $vout}\"]" \
  outputs="{\\\"$recipient_address\\\": $amount}" \
  locktime=$locktime)

# Output the raw transaction
echo "Raw Transaction Hex:"
echo $rawtxhex

# Optionally, decode the transaction to verify it
echo "Decoded Transaction:"
bitcoin-cli -regtest decoderawtransaction $rawtxhex
