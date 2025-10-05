# Token Claim Contract

A secure, gas-efficient ERC20 token claim contract with signature-based authentication. This contract allows users to claim tokens using cryptographically signed messages from a backend service, ensuring secure and verifiable token distribution.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Security Features](#security-features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contract Functions](#contract-functions)
- [Security Considerations](#security-considerations)
- [License](#license)
- [Contact](#contact)

## ✨ Features

- **Signature-Based Authentication**: Secure token claims using EIP-191 signed messages
- **Reentrancy Protection**: Built-in protection against reentrancy attacks
- **Signature Replay Prevention**: One-time use signatures prevent double-spending
- **Expiration Support**: Time-bound signatures for enhanced security
- **Admin Controls**: Owner can update token address and backend wallet
- **Emergency Withdraw**: Owner can withdraw tokens in emergency situations
- **Gas Optimized**: Efficient contract design for lower transaction costs
- **OpenZeppelin Audited**: Uses battle-tested OpenZeppelin contracts

## 🏗️ Architecture

The contract implements a signature-based claim system where:

1. Backend service generates a signature for eligible users
2. Users submit the signature along with claim parameters
3. Contract verifies the signature authenticity
4. Tokens are transferred to the user if verification passes

### Message Structure

The signed message contains:
- `recipient`: Address of the token recipient
- `amount`: Amount of tokens to claim
- `nonce`: Unique identifier to prevent replay attacks
- `deadline`: Timestamp after which the signature expires

## 🔒 Security Features

- **ReentrancyGuard**: Prevents reentrancy attacks
- **SafeERC20**: Safe token transfers using OpenZeppelin's SafeERC20 library
- **Signature Verification**: Cryptographic verification of backend signatures
- **Ownable**: Access control for administrative functions
- **Zero Address Checks**: Prevents invalid address assignments

## 🚀 Installation

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Hardhat

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd claim_contract
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory:
```env
PRIVATE_KEY=your_private_key_here
INFURA_PROJECT_ID=your_infura_project_id
ETHERSCAN_API_KEY=your_etherscan_api_key
TOKEN_CONTRACT=your_token_contract_address
BACKEND_WALLET=your_backend_wallet_address
```

## ⚙️ Configuration

### Environment Variables

- `PRIVATE_KEY`: Private key of the deployer account
- `INFURA_PROJECT_ID`: Infura project ID for RPC access
- `ETHERSCAN_API_KEY`: Etherscan API key for contract verification
- `TOKEN_CONTRACT`: Address of the ERC20 token contract
- `BACKEND_WALLET`: Address of the wallet that signs claim messages

### Hardhat Configuration

The project is configured for:
- **Sepolia Testnet**: For testing deployments
- **Ethereum Mainnet**: For production deployments

Update `hardhat.config.js` to add additional networks if needed.

## 📖 Usage

### Compile Contracts

```bash
npm run compile
```

### Run Tests

```bash
npm test
```

### Deploy to Sepolia

```bash
npm run deploy:sepolia
```

### Deploy to Mainnet

```bash
npm run deploy:mainnet
```

### Verify Contract

```bash
npx hardhat verify --network <network> <contract_address> <token_address> <backend_wallet_address>
```

## 🧪 Testing

The test suite includes comprehensive coverage for:

- Contract deployment and initialization
- Token claiming with valid signatures
- Signature replay prevention
- Expiration handling
- Invalid signature rejection
- Admin functions
- Access control

Run tests with:
```bash
