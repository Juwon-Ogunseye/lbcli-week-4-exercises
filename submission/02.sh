#!/bin/bash

set -e
set -x

# Original signed transaction that contains UTXOs
raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Decode TX to extract txid
decoded=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx")
txid=$(echo "$decoded" | jq -r '.txid')

# Inputs (vout 0 and 1), both with high sequence for locktime
sequence=4294967294
inputs="[ \
  {\"txid\":\"$txid\", \"vout\":0, \"sequence\":$sequence}, \
  {\"txid\":\"$txid\", \"vout\":1, \"sequence\":$sequence} \
]"

# Output: send exactly 0.2 BTC
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
outputs="{\"$recipient\":0.2}"

# Locktime = current block + 2000
current_block=$(bitcoin-cli -regtest getblockcount)
locktime=$((current_block + 2000))

# Create raw TX with 2 inputs and 1 output
raw_tx_new=$(bitcoin-cli -regtest createrawtransaction "$inputs" "$outputs" "$locktime")

# Sign the TX
signed_tx=$(bitcoin-cli -regtest signrawtransactionwithwallet "$raw_tx_new")
final_hex=$(echo "$signed_tx" | jq -r '.hex')

# Output final signed TX
echo "$final_hex"
