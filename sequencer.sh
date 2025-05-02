#!/bin/bash

clear
cat << "EOF"
#         ┌────────────────────────────────────┐
#         │███╗   ███╗██████╗  ██████╗ ██╗  ██╗│
#         │████╗ ████║██╔══██╗██╔════╝ ██║  ██║│
#         │██╔████╔██║██████╔╝██║  ███╗███████║│
#         │██║╚██╔╝██║██╔══██╗██║   ██║██╔══██║│
#         │██║ ╚═╝ ██║██║  ██║╚██████╔╝██║  ██║│
#         │╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝│
#         └────────────────────────────────────┘
#          created by 0xMugi
#
EOF

# Exit on any error
set -e

# Verify running on Ubuntu
if ! lsb_release -a 2>/dev/null | grep -q "Ubuntu"; then
  echo "Error: This script is designed for Ubuntu Linux only."
  exit 1
fi

# Clean up duplicate Docker repository entries
echo "Cleaning up Docker repository entries..."
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/sources.list.d/archive_uri-https_download_docker_com_linux_ubuntu-jammy.list

# Install prerequisites
echo "Installing prerequisites..."
sudo apt-get update
# Purge conflicting containerd packages
sudo apt-get purge -y containerd containerd.io 2>/dev/null || true
# Fix broken dependencies
sudo apt-get install -f -y
sudo apt-get install -y curl docker.io

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Verify Docker installation
if ! command -v docker &> /dev/null; then
  echo "Error: Docker failed to install. Try running 'sudo apt-get update && sudo apt-get install -y docker.io' manually."
  exit 1
fi

# Install Aztec CLI
echo "Installing Aztec CLI..."
bash -i <(curl -s https://install.aztec.network)

# Ensure /root/.aztec/bin is in PATH
echo "Adding /root/.aztec/bin to PATH..."
echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

# Verify aztec installation
if ! command -v aztec &> /dev/null; then
  echo "Error: Aztec CLI failed to install. Please ensure that the PATH is updated and try again."
  exit 1
fi

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

# Inform user and stop the process for editing .env file
echo "File .env telah dibuat. Silakan edit file ini dengan data Anda:"
echo "- ETHEREUM_HOSTS (contoh: Alchemy atau Infura URL)"
echo "- L1_CONSENSUS_HOST_URLS (contoh: Quicknode atau dRPC URL)"
echo "- BLOB_SINK_URL (opsional, contoh: Alchemy blob storage)"
echo "- VALIDATOR_PRIVATE_KEY (kunci privat Ethereum Anda)"
echo "- COINBASE_ADDRESS (alamat publik Ethereum Anda)"
echo "Buka file dengan: nano .env atau editor lain."
echo "Setelah selesai mengedit, tekan Enter untuk melanjutkan."
echo "Jika Anda ingin melanjutkan, pastikan Anda telah mengedit .env dengan benar."

# Wait for user to edit .env file
read -p "Tekan Enter untuk melanjutkan setelah mengedit .env..." 

echo "Melanjutkan setelah mengedit .env..."

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

echo "Dah Kelar."
