#!/bin/bash

# Amount of sats in 1 BTC
one_btc=100000000

# Amount to convert (20,000,000 sats)
amount_sat=20000000

# Convert 20,000,000 sats to BTC
amount_btc=$(echo "scale=10; $amount_sat / $one_btc" | bc | awk '{printf "%3f\n", $0}')

# Receiver address
receiver="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"

# Raw transaction hex (Use the transaction information we decoded earlier)
rawtxhex="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Decode the raw transaction to get the txid
utxo_txid=$(bitcoin-cli -regtest -rpcwallet=btrustwallet decoderawtransaction $rawtxhex | jq -r ".txid")

# Lock time calculation (6 * 24 * 14 + 25 = 2041)
locktime=2041

# Convert message to hex (ASCII to hex)
message="btrust builder 2025"
message_hex=$(echo -n "$message" | xxd -p)

# Create the raw transaction with OP_RETURN and recipient output
txhex=$(bitcoin-cli -regtest -rpcwallet=btrustwallet -named createrawtransaction inputs='''[{"txid":"'$utxo_txid'", "vout":0},{"txid":"'$utxo_txid'", "vout":1}]''' outputs='''{"'$receiver'": '$amount_btc', "data":"'$message_hex'"}''' locktime=$locktime)

# Output the raw transaction hex
echo $txhex
