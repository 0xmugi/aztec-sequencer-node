#!/bin/bash

clear
cat << "EOF"
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
EOF

# Exit on any error
set -e

# Verify running on Ubuntu
if ! lsb_release -a 2>/dev/null | grep -q "Ubuntu"; then
  echo "Error: Skrip ini hanya untuk Ubuntu Linux."
  exit 1
fi

# Install prerequisites
echo "Menginstal prerequisite..."
sudo apt-get update
sudo apt-get install -y curl ca-certificates gnupg lsb-release

# Install Docker using official repository
echo "Menginstal Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "Menginstal Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K[^"]+')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Verify Docker installation
if ! command -v docker &> /dev/null; then
  echo "Error: Docker gagal diinstal. Coba jalankan 'sudo apt-get update && sudo apt-get install -y docker-ce' secara manual."
  exit 1
fi

# Install Node.js and npm (required for Aztec CLI)
echo "Menginstal Node.js dan npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
if ! command -v npm &> /dev/null; then
  echo "Error: npm gagal diinstal."
  exit 1
fi

# Install Aztec CLI using npm
echo "Menginstal Aztec CLI..."
sudo npm install -g @aztec/cli
if ! command -v aztec-cli &> /dev/null; then
  echo "Error: Aztec CLI gagal diinstal. Pastikan npm berfungsi dengan benar."
  exit 1
fi

# Update PATH
echo "Memperbarui PATH..."
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc

# Update Aztec CLI to alpha-testnet
echo "Memperbarui Aztec CLI ke versi alpha-testnet..."
aztec-cli update alpha-testnet

# Create .env file for configuration
echo "Membuat file .env..."
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

# Prompt user to edit .env file
echo "File .env telah dibuat. Silakan edit file ini dengan data Anda:"
echo "- ETHEREUM_HOSTS (contoh: Alchemy atau Infura URL)"
echo "- L1_CONSENSUS_HOST_URLS (contoh: Quicknode atau dRPC URL)"
echo "- BLOB_SINK_URL (opsional, contoh: Alchemy blob storage)"
echo "- VALIDATOR_PRIVATE_KEY (kunci privat Ethereum Anda)"
echo "- COINBASE_ADDRESS (alamat publik Ethereum Anda)"
echo "Buka file dengan: nano .env atau editor lain."
echo "Setelah selesai mengedit, tekan Enter untuk melanjutkan."
read -p "Tekan Enter untuk melanjutkan..."

# Start the sequencer using aztec start
echo "Menjalankan Aztec sequencer..."
aztec-cli start --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls $ETHEREUM_HOSTS \
  --l1-consensus-host-urls $L1_CONSENSUS_HOST_URLS \
  --sequencer.blobSinkUrl $BLOB_SINK_URL \
  --sequencer.validatorPrivateKey $VALIDATOR_PRIVATE_KEY \
  --sequencer.coinbase $COINBASE_ADDRESS \
  --p2p.p2pIp $P2P_IP \
  --p2p.maxTxPoolSize $MAX_TX_POOL_SIZE

# Register as a validator
echo "Mendaftar sebagai validator..."
aztec-cli add-l1-validator \
  --l1-rpc-urls $ETHEREUM_HOSTS \
  --private-key $VALIDATOR_PRIVATE_KEY \
  --attester $COINBASE_ADDRESS \
  --proposer-eoa $COINBASE_ADDRESS \
  --staking-asset-handler $STAKING_ASSET_HANDLER \
  --l1-chain-id $L1_CHAIN_ID

echo "Selesai! Aztec sequencer dan validator telah diatur."