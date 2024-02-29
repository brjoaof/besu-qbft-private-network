## Private network using QBFT on Hyperledger Besu

**Script for creating a QBFT network on Hyperledger Besu using Docker.**
**Includes options for using post quantum cryptography (Dilithium, Sphincs and Falcon).**

## Prerequisites

- `docker-compose`
- `Besu Image`


## Usage

- Clone repo
- `cd besu-qbft-private-network`
- `chmod +x init-qbft.sh`
- You need to know the name of the besu image. Replace ***hyperledger/besu*** with your image name
- `./init-qbft.sh hyperledger/besu`
- For images with PQC support, made by Venturus:
- `./init-qbft.sh hyperledger/besu:pqc dilithium`
- Use your image name instead of hyperledger/besu:pqc.





