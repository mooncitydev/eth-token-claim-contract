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
npm test
```

## 🚢 Deployment

### Step-by-Step Deployment

1. **Prepare Environment**:
   - Ensure `.env` file is configured
   - Fund deployer account with ETH for gas

2. **Deploy Contract**:
   ```bash
   npm run deploy:sepolia  # For testnet
   # or
   npm run deploy:mainnet  # For mainnet
   ```

3. **Verify Contract**:
   ```bash
   npx hardhat verify --network sepolia <contract_address> <token_address> <backend_wallet>
   ```

4. **Fund Contract**:
   Transfer ERC20 tokens to the deployed contract address for users to claim.

## 📝 Contract Functions

### Public Functions

#### `claimTokens(uint256 amount, uint256 nonce, uint256 deadline, bytes memory signature)`
Claims tokens using a backend-signed message.

**Parameters:**
- `amount`: Amount of tokens to claim
- `nonce`: Unique nonce for this claim
- `deadline`: Signature expiration timestamp
- `signature`: Backend signature

**Requirements:**
- Signature must not be expired
- Signature must not have been used before
- Contract must have sufficient balance
- Signature must be valid

### View Functions

#### `isSignatureUsed(address recipient, uint256 amount, uint256 nonce, uint256 deadline)`
Checks if a signature has already been used.

#### `verifySignature(address recipient, uint256 amount, uint256 nonce, uint256 deadline, bytes memory signature)`
Verifies a signature without executing the claim.

#### `getContractBalance()`
Returns the current token balance of the contract.

### Admin Functions (Owner Only)

#### `updateTokenAddress(address _newToken)`
Updates the token contract address.

#### `updateBackendWallet(address _newBackendWallet)`
Updates the backend wallet address that signs messages.

#### `emergencyWithdraw(uint256 amount)`
Withdraws tokens from the contract (owner only).

## 🔐 Security Considerations

1. **Backend Wallet Security**: The backend wallet private key must be kept secure. Compromise of this key allows unauthorized token claims.

2. **Nonce Management**: Ensure nonces are unique and properly tracked on the backend to prevent signature reuse.

3. **Deadline Management**: Set appropriate deadlines for signatures to balance security and user experience.

4. **Token Funding**: Only fund the contract with tokens that users are eligible to claim.

5. **Access Control**: The owner address should be a multisig wallet for production deployments.

6. **Signature Format**: Backend must use the exact same message format as the contract:
   ```solidity
   keccak256(abi.encodePacked(recipient, amount, nonce, deadline))
   ```

## 📄 License

This project is licensed under the MIT License.

## 📞 Contact

**Telegram**: [@moooncity](https://t.me/moooncity)

For questions, support, or collaboration opportunities, feel free to reach out via Telegram.

---

## 🔗 Additional Resources

- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Hardhat Documentation](https://hardhat.org/docs)
- [EIP-191: Signed Data Standard](https://eips.ethereum.org/EIPS/eip-191)
- [ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)

---

**Built with ❤️ using Solidity, Hardhat, and OpenZeppelin**
