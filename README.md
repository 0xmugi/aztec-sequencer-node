# Aztec Sequencer Node Automatic Installer

This script automates the installation and configuration of an Aztec Sequencer Node on Ubuntu servers. It streamlines the process, handling system updates, dependency installation, and node setup with minimal user intervention.

## Features
- **Automated System Setup**: Installs system updates and required prerequisites.
- **Docker Integration**: Automatically installs Docker if not already present.
- **Aztec Sandbox Deployment**: Configures and deploys the Aztec Sandbox environment.
- **Server IP Detection**: Automatically detects your server’s public IP address.
- **Custom Port Configuration**: Allows customization of TCP/UDP and HTTP ports.
- **One-Click Deployment**: Simplifies node installation and startup with a single script.

## Requirements
- **Operating System**: Ubuntu (20.04 or later recommended).
- **Minimum Hardware Specifications**:
  - 8-core CPU
  - 16 GB RAM
  - 1 TB NVMe SSD
  - 25 Mbps upload/download bandwidth
- **Network**: Stable internet connection with open ports for node communication.

## Installation
1. Download and execute the installation script:
   ```bash
   wget https://raw.githubusercontent.com/0xmugi/aztec-sequencer-node/refs/heads/main/aztec.sh
   chmod +x aztec.sh
   ./aztec.sh
   ```
2. Follow the on-screen prompts to configure your node:
   - Confirm or manually enter your server’s public IP address.
   - Provide a valid Ethereum private key.
   - Optionally configure custom ports (default: TCP/UDP 40400, HTTP 8080).

The script will install dependencies, set up the Aztec Sequencer Node, and start it automatically.

## Usage
Once installed, the Aztec Sequencer Node runs automatically. Use the following commands to manage your node:

- **Check Node Logs**:
  ```bash
  cd ~/aztec-sequencer && docker-compose logs -f
  ```
- **Stop the Node**:
  ```bash
  cd ~/aztec-sequencer && docker-compose down -v
  ```
- **Restart the Node**:
  ```bash
  cd ~/aztec-sequencer && docker restart aztec-sequencer
  ```

## Customization
During installation, you can customize the following:
- **Network Endpoints**: Specify Ethereum RPC and Beacon API endpoints.
- **Ports**:
  - TCP/UDP ports (default: 40400)
  - HTTP port (default: 8080)
- **Configuration Files**: All settings are stored in:
  - `~/aztec-sequencer/.env`
  - `~/aztec-sequencer/docker-compose.yml`

Modify these files to adjust settings post-installation if needed.

## Troubleshooting
If you encounter issues, try the following:
- **Check Logs**: Review node logs for specific error messages.
- **Verify Hardware**: Ensure your server meets the minimum hardware requirements.
- **Validate Private Key**: Confirm your Ethereum private key is correct and funded.
- **Check Ports**: Verify that the specified ports (40400, 8080, or custom) are open in your firewall.
- **Network Issues**: Ensure your server has a stable internet connection.

For additional help, consult the [official Aztec Network documentation](https://docs.aztec.network/).

## Support
For questions or issues, refer to the [Aztec Network documentation](https://docs.aztec.network/) or join the Aztec community forums for assistance.

## License
This script is distributed under the [MIT License](LICENSE). You are free to use, modify, and distribute it as needed.

---

**Disclaimer**: Ensure you understand the risks of running a node, including the need to secure your Ethereum private key. The authors are not responsible for any loss or damage caused by the use of this script.
