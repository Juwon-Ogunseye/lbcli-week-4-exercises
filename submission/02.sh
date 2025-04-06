#!/bin/bash

# Enable full command tracing (so GitHub Actions will show all executed commands)
set -x

# Current block (for calculating locktime)
current_block=25  # Adjust this as per your actual current block height in regtest

# Decode the raw transaction to extract UTXO details
transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"
decoded_tx=$(bitcoin-cli -regtest decoderawtransaction "$transaction")

# Extract UTXO details
utxo_txid=$(echo "$decoded_tx" | jq -r '.vin[0].txid')
utxo_vout=$(echo "$decoded_tx" | jq -r '.vin[0].vout')

# Debug: Print the UTXO txid and vout (output will appear in GitHub Actions logs)
echo "UTXO TXID: $utxo_txid"
echo "UTXO VOUT: $utxo_vout"

# Recipient address and amount to send
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount=20000000  # Amount in satoshis

# Calculate locktime (current block height + 2 weeks worth of blocks (20160 blocks))
locktime=$(($current_block + 20160))

# Debug: Print the locktime value (this is the key change)
echo "Locktime: $locktime"

# Create the raw transaction with locktime
rawtxhex=$(bitcoin-cli -regtest createrawtransaction \
  "[ { \"txid\": \"$utxo_txid\", \"vout\": $utxo_vout } ]" \
  "{ \"$recipient\": $amount }" \
  "$locktime")

# Debug: Print the generated raw transaction hex (output will appear in GitHub Actions logs)
echo "Generated Raw Transaction Hex: $rawtxhex"

# Expected raw transaction hex (to compare)
EXPECTED_OUTPUT="0200000002160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230000000000fdffffff160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230100000000fdffffff01002d31010000000017a91421ed90762e16eaaea188aae19142e5b25bf75d2387f9070000"

# Compare generated transaction with expected output
if [[ "$rawtxhex" == "$EXPECTED_OUTPUT" ]]; then
  echo "✅ Success: Raw Locked Transaction generation passed!"
else
  echo "❌ Error: Raw Locked Transaction generation failed!"
  exit 1
fi
