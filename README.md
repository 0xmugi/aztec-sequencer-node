# Node Sequencer Aztec

Panduan simpel buat jalanin **node sequencer Aztec** di testnet alpha pake Ubuntu Linux. Node ini ngurus transaksi, bikin blok, dan kirim ke Layer 1 (L1) setelah dicek validator.

## Apa Aja Yang Dibutuhin

- Komputer Ubuntu Linux dengan terminal.
- Docker sama Docker Compose udah terinstall.
- Kunci privat Ethereum + alamat publik buat validator.
- Sepolia ETH buat gas (coba [Sepolia PoW Faucet](https://sepolia.powfaucet.com/) atau tanya di Discord Aztec).
- RPC L1:
  - Eksekusi (misal: Alchemy, Infura).
  - Konsensus (misal: Quicknode, dRPC).
- (Opsional) URL buat penyimpanan blob (misal: Alchemy).
- Port 40400 (TCP/UDP) diforward di router ke IP lokal.
- IP eksternal (cek pake `curl ifconfig.me`).

Gabung [Discord Aztec](https://discord.gg/aztec) buat bantuan.

## Cara Jalanin

### 1. **Klon Repo**

   Pertama, kloning repository ke sistem kamu:

   ```bash
   git clone https://github.com/0xmugi/aztec-sequencer-node.git
   cd aztec-sequencer-node
   ```

### 2. **Jalanin Skrip**

   File `sequencer.sh` bakal menginstal Aztec CLI, membuat file `.env`, dan menunggu kamu untuk mengedit file tersebut sebelum menjalankan sequencer.

   Pastikan skrip bisa dijalankan dengan memberikan izin eksekusi:

   ```bash
   chmod +x sequencer.sh
   ./sequencer.sh
   ```

### 3. **Edit `.env`**

   Setelah skrip dijalankan, file `.env` akan dibuat secara otomatis. Skrip akan meminta kamu untuk mengeditnya sebelum melanjutkan. Buka file `.env` menggunakan `nano` atau editor lain:

   ```bash
   nano .env
   ```

   Di dalam file `.env`, kamu perlu mengisi beberapa informasi yang diperlukan untuk menjalankan node:

   - `ETHEREUM_HOSTS`: URL RPC untuk jaringan Ethereum L1 (contoh: Alchemy).
   - `L1_CONSENSUS_HOST_URLS`: URL RPC untuk konsensus L1 (contoh: dRPC).
   - `BLOB_SINK_URL`: URL penyimpanan blob (optional, jika digunakan).
   - `VALIDATOR_PRIVATE_KEY`: Kunci privat Ethereum untuk validator.
   - `COINBASE_ADDRESS`: Alamat publik Ethereum untuk coinbase.

   **Contoh file `.env`**:

   ```plaintext
   ETHEREUM_HOSTS=https://eth-sepolia.g.alchemy.com/v2/your-alchemy-key
   L1_CONSENSUS_HOST_URLS=https://sepolia-beacon.drpc.org
   BLOB_SINK_URL=https://your-blob-sink-url
   VALIDATOR_PRIVATE_KEY=0xYourPrivateKey
   COINBASE_ADDRESS=0xYourPublicAddress
   P2P_IP=ip-eksternal-anda
   P2P_PORT=40400
   MAX_TX_POOL_SIZE=1000000000
   L1_CHAIN_ID=11155111
   STAKING_ASSET_HANDLER=0xF739D03e98e23A7B65940848aBA8921fF3bAc4b2
   LOG_LEVEL=debug
   DATA_DIRECTORY=/data
   ```

   Setelah selesai mengedit `.env`, simpan dan keluar dari editor, kemudian tekan Enter di terminal untuk melanjutkan proses.

### 4. **Menjalankan Sequencer**

   Setelah file `.env` selesai diedit, kamu bisa melanjutkan dengan menjalankan sequencer:

   ```bash
   ./sequencer.sh
   ```

   Skrip ini akan meluncurkan node Aztec sebagai sequencer.

### 5. **Daftar Validator**

   Setelah node berhasil disinkronkan, skrip akan mendaftarkan node kamu sebagai validator. Jika kuota validator harian penuh, coba lagi besok.

   Untuk informasi lebih lanjut tentang validator, cek [blog Aztec](https://aztec.network/blog).

## Pake Docker Compose (Opsional)

Kalo mau cara lain, pake Docker Compose. Bikin file `docker-compose.yml`:

```yaml
name: aztec-node
services:
  node:
    image: aztecprotocol/aztec:0.85.0-alpha-testnet.5
    environment:
      - ETHEREUM_HOSTS=${ETHEREUM_HOSTS}
      - L1_CONSENSUS_HOST_URLS=${L1_CONSENSUS_HOST_URLS}
      - BLOB_SINK_URL=${BLOB_SINK_URL}
      - VALIDATOR_PRIVATE_KEY=${VALIDATOR_PRIVATE_KEY}
      - COINBASE_ADDRESS=${COINBASE_ADDRESS}
      - P2P_IP=${P2P_IP}
      - P2P_PORT=${P2P_PORT}
      - MAX_TX_POOL_SIZE=${MAX_TX_POOL_SIZE}
      - LOG_LEVEL=${LOG_LEVEL}
      - DATA_DIRECTORY=${DATA_DIRECTORY}
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'
    ports:
      - 40400:40400/tcp
      - 40400:40400/udp
      - 8080:8080
    volumes:
      - ./data:/data
    network_mode: host
```

Jalanin:

```bash
docker-compose up -d
```

## Kalo Ada Masalah

- **Docker Gagal Instal**: Kalo ada error soal `containerd` atau `containerd.io`, skrip udah otomatis hapus paket konflik. Kalo masih gagal, coba manual: `sudo apt-get remove containerd containerd.io && sudo apt-get install docker.io`.
- **L1 Gak Connect**: Kalo pake klien Ethereum lokal, pastiin `network_mode: host` ada di Docker Compose.
- **Port Gak Keforward**: Cek port 40400 (TCP/UDP) udah dibuka di router.
- **Kuota Validator Penuh**: Coba daftar lagi besok kalo gagal.
- **Cek Log**: Liat error pake `docker logs <container_id>` atau set `LOG_LEVEL=debug` di `.env`.

## Mau Bantu?

Punya ide atau perbaikan? Buka **issue** atau kirim **pull request** di GitHub!

## Butuh Bantuan?

Gabung [Discord Aztec](https://discord.gg/aztec) atau cek [dokumentasi CLI Aztec](https://aztec.network/cli).
