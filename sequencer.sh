#!/bin/bash

# ┌────────────────────────────────────┐
# │███╗   ███╗██████╗  ██████╗ ██╗  ██╗│
# │████╗ ████║██╔══██╗██╔════╝ ██║  ██║│
# │██╔████╔██║██████╔╝██║  ███╗███████║│
# │██║╚██╔╝██║██╔══██╗██║   ██║██╔══██║│
# │██║ ╚═╝ ██║██║  ██║╚██████╔╝██║  ██║│
# │╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝│
# └────────────────────────────────────┘                          
#      created by 0xMugi
#                               

# Exit on any error
set -e

# Verify running on Ubuntu
if ! lsb_release -a 2>/dev/null | grep -q "Ubuntu"; then
  echo "Error: This script is designed for Ubuntu Linux only."
  exit 1
fi

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get update
sudo apt-get install -y curl docker.io

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Install Aztec CLI
echo "Installing Aztec CLI..."
curl -sSL https://aztec.network/install | bash
source ~/.bashrc  # Reload shell to update PATH

# Update Aztec CLI to the correct version for alpha-testnet
echo "Updating Aztec CLI to alpha-testnet version..."
aztec-up alpha-testnet

# Create .env file for configuration
echo "Creating .env file..."
cat << EOF > .env
ETHEREUM_HOSTS=https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key
L1_CONSENSUS_HOST_URLS=https://sepolia-beacon.drpc.org
BLOB_SINK_URL=https://your-blob-sink-url
VALIDATOR_PRIVATE_KEY=0xYourPrivateKey
COINBASE_ADDRESS=0xYourPublicAddress
P2P_IP=$(curl -s ifconfig.me)
P2P_PORT=40400
MAX_TX_POOL_SIZE=1000000000
L1_CHAIN_ID=11155111
STAKING_ASSET_HANDLER=0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2
LOG_LEVEL=debug
DATA_DIRECTORY=/data
EOF

# Start the sequencer using aztec start
echo "Starting Aztec sequencer..."
aztec start --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls $ETHEREUM_HOSTS \
  --l1-consensus-host-urls $L1_CONSENSUS_HOST_URLS \
  --sequencer.blobSinkUrl $BLOB_SINK_URL \
  --sequencer.validatorPrivateKey $VALIDATOR_PRIVATE_KEY \
  --sequencer.coinbase $COINBASE_ADDRESS \
  --p2p.p2pIp $P2P_IP \
  --p2p.maxTxPoolSize $MAX_TX_POOL_SIZE

# Register as a validator
echo "Registering as a validator..."
aztec add-l1-validator \
  --l1-rpc-urls $ETHEREUM_HOSTS \
  --private-key $VALIDATOR_PRIVATE_KEY \
  --attester $COINBASE_ADDRESS \
  --proposer-eoa $COINBASE_ADDRESS \
  --staking-asset-handler $STAKING_ASSET_HANDLER \
  --l1-chain-id $L1_CHAIN_ID

echo "Pengaturan sequencer selesai! Gabung ke Discord Aztec untuk bantuan lebih lanjut."