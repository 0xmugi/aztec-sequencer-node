# Pengaturan Node Sequencer Aztec

![Aztec Logo](https://via.placeholder.com/150x50.png?text=Aztec+Network)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
[![Discord](https://img.shields.io/discord/123456789012345678?logo=discord&label=Discord)](https://discord.gg/aztec)

Selamat datang di repositori untuk mengatur dan menjalankan **node sequencer Aztec** pada testnet alpha di sistem Ubuntu Linux. Node sequencer berperan penting dalam mengurutkan transaksi, menghasilkan blok, dan mengirimkannya ke Layer 1 (L1) setelah divalidasi oleh komite validator.

## Daftar Isi

- [Prasyarat](#prasyarat)
- [Mulai Cepat](#mulai-cepat)
- [Pengaturan Lanjutan dengan Docker Compose](#pengaturan-lanjutan-dengan-docker-compose)
- [Pemecahan Masalah](#pemecahan-masalah)
- [Kontribusi](#kontribusi)
- [Dukungan](#dukungan)
- [Lisensi](#lisensi)

## Prasyarat

Sebelum memulai, pastikan Anda telah menyiapkan:

- **Sistem Operasi**: Ubuntu Linux dengan akses terminal.
- **Perangkat Lunak**: Docker dan Docker Compose terinstal.
- **Kunci Ethereum**: Kunci privat dan alamat publik untuk operasi validator.
- **Sepolia ETH**: Untuk biaya gas, dapatkan dari [Sepolia PoW Faucet](https://sepolia.powfaucet.com/) atau tanyakan di komunitas Discord Aztec.
- **RPC L1**:
  - Klien eksekusi (contoh: Alchemy, Infura).
  - Klien konsensus (contoh: Quicknode, dRPC).
- **Layanan Blob** (opsional): URL penyimpanan blob (contoh: Alchemy).
- **Jaringan**: Port 40400 (TCP/UDP) diteruskan pada router ke IP lokal komputer.
- **IP Eksternal**: Dapatkan dengan menjalankan `curl ifconfig.me`.

**Gabung ke [Discord Aztec](https://discord.gg/aztec)** untuk bantuan dan diskusi komunitas.

## Mulai Cepat

Ikuti langkah-langkah berikut untuk mengatur node sequencer:

1. **Klon Repositori**

   ```bash
   git clone https://github.com/nama-pengguna-anda/aztec-sequencer-node.git
   cd aztec-sequencer-node
   ```

2. **Jalankan Skrip Pengaturan**

   Skrip `setup_sequencer.sh` akan menginstal Aztec CLI, mengatur lingkungan, dan menjalankan sequencer.

   ```bash
   chmod +x setup_sequencer.sh
   ./setup_sequencer.sh
   ```

3. **Konfigurasi File `.env`**

   Edit file `.env` dengan informasi spesifik Anda:

   - `ETHEREUM_HOSTS`: URL RPC klien eksekusi L1.
   - `L1_CONSENSUS_HOST_URLS`: URL RPC klien konsensus L1.
   - `BLOB_SINK_URL`: URL layanan penyimpanan blob (opsional).
   - `VALIDATOR_PRIVATE_KEY`: Kunci privat Ethereum.
   - `COINBASE_ADDRESS`: Alamat publik Ethereum.

   **Contoh `.env`**:
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

4. **Daftar sebagai Validator**

   Skrip akan mendaftarkan node Anda sebagai validator setelah sinkronisasi selesai. Jika kuota validator harian penuh, coba lagi nanti. Informasi lebih lanjut ada di [blog Aztec](https://aztec.network/blog).

## Pengaturan Lanjutan dengan Docker Compose

Untuk pengguna lanjutan, Anda dapat menjalankan sequencer menggunakan Docker Compose. Buat file `docker-compose.yml`:

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

Jalankan Docker Compose:

```bash
docker-compose up -d
```

## Pemecahan Masalah

- **Akses L1**: Jika menggunakan klien Ethereum lokal, pastikan `network_mode: host` digunakan di Docker Compose untuk Ubuntu.
- **Penerusan Port**: Verifikasi bahwa port 40400 (TCP/UDP) diteruskan ke komputer Anda.
- **Kuota Validator**: Jika pendaftaran gagal karena kuota harian, coba lagi keesokan harinya.
- **Log**: Periksa log dengan `docker logs <container_id>` atau setel `LOG_LEVEL=debug` di `.env` untuk detail lebih lanjut.

## Kontribusi

Kami menyambut kontribusi! Silakan ajukan **pull request** atau buka **issue** di GitHub untuk saran atau perbaikan.

## Dukungan

Untuk bantuan, bergabunglah dengan [Discord Aztec](https://discord.gg/aztec) atau kunjungi [referensi CLI Aztec](https://aztec.network/cli) untuk dokumentasi lebih lanjut.

## Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE). Lihat file `LICENSE` untuk detail.