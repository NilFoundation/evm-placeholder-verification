#!/bin/sh
if [ -f $1 ]; then
  rm -f time.log
#  echo "Name Time Status Verification_Gas" > time.log
/Users/Zerg/Projects/new_solana_master/cmake-build-debug/bin/state-mock/state-proof-mock > tmp.txt
/Users/Zerg/Projects/new_solana_master/cmake-build-debug/bin/state-mock/state-proof-mock > tmp.txt
/Users/Zerg/Projects/new_solana_master/cmake-build-debug/bin/state-mock/state-proof-mock > tmp.txt
#  state-proof-mock | state-proof-gen ; cat blob.txt | node verifyRedshiftUnifiedAdditionGas.js $1
  cat blob.txt | node verifyRedshiftUnifiedAdditionGas.js $1
  node printTable.js
#  python3 create_pretty_table.py
else
    echo "Secret on path $1 does not exist."
fi
