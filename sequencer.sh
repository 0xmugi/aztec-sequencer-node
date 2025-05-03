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

set -e

# Cek apakah sudah diinstal
function is_installed {
  command -v "$1" &> /dev/null
}

# Validasi URL sederhana
function is_valid_url {
  local url=$1
  if [[ $url =~ ^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$ ]]; then
    return 0
  else
    return 1
  fi
}

# Verifikasi Ubuntu
if ! lsb_release -a 2>/dev/null | grep -q "Ubuntu"; then
  echo "Error: Script ini hanya untuk Ubuntu Linux."
  exit 1
fi

# Install Docker & Docker Compose jika belum terinstal
if ! is_installed docker; then
  echo "Menginstal Docker dan Docker Compose..."

  # Cleanup repo lama
  sudo rm -f /etc/apt/sources.list.d/docker.list
  sudo rm -f /etc/apt/sources.list.d/archive_uri-https_download_docker_com_linux_ubuntu-jammy.list

  sudo apt-get update
  sudo apt-get purge -y containerd containerd.io 2>/dev/null || true
  sudo apt-get install -f -y
  sudo apt-get install -y curl docker.io

  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  sudo systemctl start docker
  sudo systemctl enable docker
  sudo usermod -aG docker $USER
else
  echo "Docker dan Docker Compose sudah terinstal."
fi

# Install Aztec CLI jika belum terinstal
if ! is_installed aztec; then
  echo "Menginstal Aztec CLI..."
  bash -i <(curl -s https://aztec.network/install)

  echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bash_profile
  source ~/.bash_profile
else
  echo "Aztec CLI sudah terinstal."
fi

# Update ke alpha-testnet
echo "Memastikan Aztec CLI versi alpha-testnet..."
aztec-up alpha-testnet

# Buat folder data jika belum ada
if [ ! -d "/data" ]; then
  echo "Membuat folder data di /data..."
  sudo mkdir -p /data
  sudo chmod -R 777 /data
else
  echo "Folder /data sudah ada."
fi

# Buat file .env hanya jika belum ada
if [ ! -f .env ]; then
  echo "Membuat file .env..."

  cat << EOF > .env
ETHEREUM_HOSTS=https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key
L1_CONSENSUS_HOST_URLS=https://sepolia-beacon.quicknode.com/your-key
BLOB_SINK_URL=
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

  echo "File .env telah dibuat. Silakan isi dengan data Anda:"
  echo "- ETHEREUM_HOSTS: Dapatkan dari Alchemy (https://www.alchemy.com/) atau Infura."
  echo "- L1_CONSENSUS_HOST_URLS: Dapatkan dari Quicknode (https://www.quicknode.com/) atau dRPC."
  echo "- BLOB_SINK_URL: Kosongkan jika tidak punya, atau tanya di Discord Aztec."
  echo "- VALIDATOR_PRIVATE_KEY: Buat akun baru di Metamask, export kunci privat."
  echo "- COINBASE_ADDRESS: Alamat publik dari akun Metamask."
  echo "JANGAN gunakan kunci privat yang pernah dishare!"
  echo ""
  echo "Edit file dengan: nano .env"
  read -p "Tekan Enter setelah selesai mengedit .env..."
else
  echo "File .env sudah ada. Pastikan data di dalamnya valid."
fi

# Load environment variable dari file .env
export $(grep -v '^#' .env | xargs)

# Cek placeholder values
if grep -q "your-alchemy-key\|your-key\|0xYourPrivateKey\|0xYourPublicAddress" .env; then
  echo "Peringatan: File .env masih berisi nilai placeholder (contoh: your-alchemy-key, 0xYourPrivateKey, 0xYourPublicAddress)."
  echo "Ganti dengan data valid:"
  echo "- Daftar di Alchemy (https://www.alchemy.com/) untuk ETHEREUM_HOSTS."
  echo "- Daftar di Quicknode (https://www.quicknode.com/) untuk L1_CONSENSUS_HOST_URLS."
  echo "- Buat kunci baru di Metamask untuk VALIDATOR_PRIVATE_KEY dan COINBASE_ADDRESS."
  echo "Node tidak akan jalan dengan benar jika ini tidak diperbaiki."
  read -p "Tekan Enter untuk melanjutkan (atau Ctrl+C untuk periksa ulang)..."
fi

# Validasi URL RPC
if ! is_valid_url "$ETHEREUM_HOSTS"; then
  echo "Error: ETHEREUM_HOSTS ($ETHEREUM_HOSTS) bukan URL valid. Perbaiki di .env."
  exit 1
fi
if ! is_valid_url "$L1_CONSENSUS_HOST_URLS"; then
  echo "Error: L1_CONSENSUS_HOST_URLS ($L1_CONSENSUS_HOST_URLS) bukan URL valid. Perbaiki di .env."
  exit 1
fi

# Jalankan Aztec node
echo "Menjalankan Aztec sequencer..."
aztec start --node --archiver --sequencer \
  --network alpha-testnet \
  --l1-rpc-urls "$ETHEREUM_HOSTS" \
  --l1-consensus-host-urls "$L1_CONSENSUS_HOST_URLS" \
  --sequencer.blobSinkUrl "$BLOB_SINK_URL" \
  --sequencer.validatorPrivateKey "$VALIDATOR_PRIVATE_KEY" \
  --sequencer.coinbase "$COINBASE_ADDRESS" \
  --p2p.p2pIp "$P2P_IP" \
  --p2p.maxTxPoolSize "$MAX_TX_POOL_SIZE" &

# Tunggu sebentar untuk pastikan node mulai
sleep 5

# Cek status node
echo "Mengecek status node..."
if docker ps | grep -q "aztecprotocol/aztec"; then
  echo "Node Aztec berjalan di Docker. Container ID:"
  docker ps --filter "ancestor=aztecprotocol/aztec" --format "{{.ID}} {{.Image}}"
  echo "Lihat log dengan: docker logs <CONTAINER_ID>"
else
  echo "Node mungkin jalan di terminal atau gagal start."
  echo "Cek proses: ps aux | grep aztec"
  echo "Cek log di /data (atau set DATA_DIRECTORY di .env)."
fi

# Daftarkan validator
echo "Mendaftarkan validator ke Layer 1..."
aztec add-l1-validator \
  --l1-rpc-urls "$ETHEREUM_HOSTS" \
  --private-key "$VALIDATOR_PRIVATE_KEY" \
  --attester "$COINBASE_ADDRESS" \
  --proposer-eoa "$COINBASE_ADDRESS" \
  --staking-asset-handler "$STAKING_ASSET_HANDLER" \
  --l1-chain-id "$L1_CHAIN_ID"

echo "🚀 Proses selesai. Node Aztec sedang berjalan!"
echo ""
echo "Untuk menghentikan node:"
echo "- Jika di Docker: docker stop <CONTAINER_ID>"
echo "- Jika di terminal: Tekan Ctrl+C"
echo "- Cek status: docker ps atau ps aux | grep aztec"
echo "Lihat log untuk error: docker logs <CONTAINER_ID> atau di /data"
echo "Jika ada error (misal Rollup__InvalidArchive), cek Discord Aztec: https://discord.gg/aztec"