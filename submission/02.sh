#!/bin/bash

# Enable debugging so each command is printed
set -x

# Provided raw transaction
transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Decode the raw transaction using bitcoin-cli
decodedtx=$(bitcoin-cli -regtest decoderawtransaction "$transaction")

# Extract txid and vout using jq
txid=$(echo "$decodedtx" | jq -r '.vin[0].txid')
vout=$(echo "$decodedtx" | jq -r '.vin[0].vout')

# Define the recipient address and amount to send
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount=20000000  # Amount in satoshis (20,000,000 satoshis)

# Define the locktime (2 weeks in block height, assuming 10 minutes per block)
locktime=20160  # 2 weeks (in blocks)

# Generate the raw transaction with the extracted txid and vout
rawtx=$(bitcoin-cli -regtest createrawtransaction \
'[ { "txid": "'$txid'", "vout": '$vout' } ]' \
'{ "'$recipient'": '$amount' }' $locktime)

echo "Generated Raw Transaction Hex: "
echo $rawtx

# Decode the generated raw transaction to see if it’s correct
decodedtx2=$(bitcoin-cli -regtest decoderawtransaction "$rawtx")

echo "Decoded Raw Transaction Hex: "
echo $decodedtx2

# Disable debugging after execution
set +x
