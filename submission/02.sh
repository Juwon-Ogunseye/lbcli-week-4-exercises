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

# Print the extracted txid and vout for debugging
echo "Extracted txid: $txid"
echo "Extracted vout: $vout"

# Define the recipient address and amount to send
recipient="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
amount=20000000  # Amount in satoshis (20,000,000 satoshis)

# Define locktime (2 weeks worth of blocks, as given)
locktime=20160

# Create the raw transaction with the extracted txid, vout, and locktime
rawtx=$(bitcoin-cli -regtest createrawtransaction \
'[ { "txid": "'$txid'", "vout": '$vout' } ]' \
'{ "'$recipient'": '$amount' }' $locktime)

echo "Generated Raw Transaction Hex: "
echo $rawtx

# Decode the generated raw transaction to see if it’s correct
decodedtx2=$(bitcoin-cli -regtest decoderawtransaction "$rawtx")

echo "Decoded Raw Transaction Hex: "
echo $decodedtx2

# Define the expected output (you can change this if the expected output is different)
EXPECTED_OUTPUT="0200000002160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230000000000fdffffff160ee5dd146316bb3400ede0d4ad512ab9c1ede486ab5a119a2ee9d4379fc1230100000000fdffffff01002d31010000000017a91421ed90762e16eaaea188aae19142e5b25bf75d2387f9070000"

# Check if the generated raw transaction matches the expected output
if [[ "$rawtx" == "$EXPECTED_OUTPUT" ]]; then
    echo "✅ Success: Raw Locked Transaction generation passed!"
else
    echo "❌ Error: Raw Locked Transaction generation failed!"
    echo "Generated Transaction: $rawtx"
    echo "Expected Transaction: $EXPECTED_OUTPUT"
    exit 1
fi

# Disable debugging after execution
set +x
