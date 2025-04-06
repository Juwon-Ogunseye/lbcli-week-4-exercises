#!/bin/bash

set -e

# 1. Provided raw transaction
raw_tx="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# 2. Decode it to get txid and vout
decoded=$(bitcoin-cli -regtest decoderawtransaction "$raw_tx")
txid=$(echo "$decoded" | jq -r '.txid')
vout=$(echo "$decoded" | jq -r '.vout[0].n')

# 3. Locktime: current block height + 2000 blocks (~2 weeks)
current_block=$(bitcoin-cli -regtest getblockcount)
locktime=$((current_block + 2000))

# 4. Destination address and amount
address="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount=0.2  # BTC (20,000,000 sats)

# 5. Construct the raw transaction with locktime
raw_tx_new=$(bitcoin-cli -regtest createrawtransaction \
"[{\"txid\":\"$txid\",\"vout\":$vout}]" \
"[{\"$address\":$amount}]" \
"$locktime")

# 6. Sign it with wallet (no need for private key)
signed_tx=$(bitcoin-cli -regtest signrawtransactionwithwallet "$raw_tx_new")
final_hex=$(echo "$signed_tx" | jq -r '.hex')

# 7. Broadcast the transaction
txid_sent=$(bitcoin-cli -regtest sendrawtransaction "$final_hex")

# 8. Print result
echo "✔️ Transaction sent successfully!"
echo "🔑 TXID: $txid_sent"
echo "⏳ Timelocked until block: $locktime"
