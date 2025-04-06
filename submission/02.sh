#!/bin/bash

set -e
set -x

# Original signed transaction that contains UTXOs
raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Decode the transaction to extract txid and amounts from the UTXOs
decoded=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx")
txid=$(echo "$decoded" | jq -r '.txid')

# Extract the amounts for vout 0 and vout 1
vout0_amount=$(echo "$decoded" | jq -r '.vout[0].value')
vout1_amount=$(echo "$decoded" | jq -r '.vout[1].value')

# Total input amount (combine vout0 and vout1)
total_input=$(echo "$vout0_amount + $vout1_amount" | bc)

# Amount to send to recipient (20,000,000 satoshis = 0.2 BTC)
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
recipient_amount=0.2  # 0.2 BTC

# Estimated fee (adjust as needed)
fee=0.0002  # 0.0002 BTC

# Calculate change (remaining balance after sending the recipient amount and fee)
change=$(echo "$total_input - $recipient_amount - $fee" | bc)

# Get change address from the wallet
change_address=$(bitcoin-cli -regtest getrawchangeaddress)

# Create the inputs array (with high sequence to ensure no locktime issue)
sequence=4294967294
inputs="[ \
  {\"txid\":\"$txid\", \"vout\":0, \"sequence\":$sequence}, \
  {\"txid\":\"$txid\", \"vout\":1, \"sequence\":$sequence} \
]"

# Create the outputs JSON with recipient and change address
outputs="{\"$recipient\":$recipient_amount, \"$change_address\":$change}"

# Set current block to 25 (as specified)
current_block=25

# Locktime = current block + 2016 (for exactly 2 weeks later)
locktime=$((current_block + 2016))

# Create the raw transaction
raw_tx_new=$(bitcoin-cli -regtest createrawtransaction "$inputs" "$outputs" "$locktime")

# Sign the transaction
signed_tx=$(bitcoin-cli -regtest signrawtransactionwithwallet "$raw_tx_new")
final_hex=$(echo "$signed_tx" | jq -r '.hex')

# Output the final signed transaction
echo "Signed Transaction HEX:"
echo "$final_hex"
