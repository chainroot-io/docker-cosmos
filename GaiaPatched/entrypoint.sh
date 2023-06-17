#!/bin/sh

CONFIG_PATH=$HOME/.gaia/config

envsubst < $HOME/config-sample/app.toml > $CONFIG_PATH/app.toml
envsubst < $HOME/config-sample/client.toml > $CONFIG_PATH/client.toml
envsubst < $HOME/config-sample/config.toml > $CONFIG_PATH/config.toml

if [ ! -f $HOME/.gaia/config/genesis.json ]; then 
  if [ $CLIENT__CHAIN_ID = "cosmoshub-4" ]; then
    wget https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/genesis.cosmoshub-4.json.gz
    gzip -d genesis.cosmoshub-4.json.gz
    mv genesis.cosmoshub-4.json $HOME/.gaia/config/genesis.json
    wget -O $CONFIG_PATH/addrbook.json https://dl2.quicksync.io/json/addrbook.cosmos.json
    #Download snapshot
    wget -O snapshot.tar.lz4 https://snapshots.polkachu.com/snapshots/cosmos/cosmos_$SNAPSHOT_BLOCK_HEIGHT.tar.lz4
    #Extract data
    lz4 -c -d cosmos_$SNAPSHOT_BLOCK_HEIGHT.tar.lz4  | tar -x -C $HOME/.gaia
  elif [ $CLIENT__CHAIN_ID = "theta-testnet-001" ]; then
    wget https://github.com/cosmos/testnets/raw/master/public/genesis.json.gz
    gzip -d genesis.json.gz
    mv genesis.json $CONFIG_PATH/genesis.json
  fi
fi

if [ ! -f $HOME/.gaia/cosmovisor/current/bin/gaiad ]; then
  #Init Cosmovisor
  cosmovisor init /usr/local/bin/gaiad
fi

cosmovisor run start