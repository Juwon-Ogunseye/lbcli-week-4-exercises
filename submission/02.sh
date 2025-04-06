#!/bin/bash

# Enable debugging so each command is printed
set -x

# Define the transaction ID and vout from the given UTXO
txid="c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef7725"
vout=0

# Define the recipient address and amount to send
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount=20000000  # Amount in satoshis

# Define the locktime (2 weeks in block height, assuming 10 minutes per block)
locktime=20160  # 2 weeks (in blocks)

# Generate the raw transaction
rawtx=$(bitcoin-cli -regtest createrawtransaction \
'[ { "txid": "'$txid'", "vout": '$vout' } ]' \
'{ "'$recipient'": '$amount' }' $locktime)

echo "Generated Raw Transaction Hex: "
echo $rawtx

# Decode the generated raw transaction to see if it’s correct
decodedtx=$(bitcoin-cli -regtest decoderawtransaction "$rawtx")

echo "Decoded Raw Transaction Hex: "
echo $decodedtx

# Disable debugging after execution
set +x
