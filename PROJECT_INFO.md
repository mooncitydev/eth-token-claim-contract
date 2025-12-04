# Project Information

## 📦 Recommended Repository Name

**Primary Recommendation:**
```
token-claim-contract
```

**Alternative Options:**
- `erc20-signature-claim`
- `signature-based-token-claim`
- `secure-token-claim-contract`
- `token-claim-smart-contract`

## 📝 Project Summary

A production-ready, secure ERC20 token claim smart contract that enables signature-based token distribution. The contract allows users to claim tokens using cryptographically signed messages from a backend service, providing a secure and gas-efficient method for token airdrops, rewards, and distribution programs.

### Key Features:
- **Signature-Based Authentication**: Uses EIP-191 signed messages for secure token claims
- **Replay Attack Prevention**: One-time use signatures prevent double-spending
- **Time-Bound Claims**: Signature expiration mechanism for enhanced security
- **Gas Optimized**: Efficient contract design using OpenZeppelin's battle-tested libraries
- **Admin Controls**: Flexible management functions for token and backend wallet updates
- **Emergency Withdraw**: Safety mechanism for contract owner

### Use Cases:
- Token airdrops and distributions
- Reward programs
- Token vesting and claim systems
- Whitelist-based token sales
- Community rewards and incentives

## 🏷️ Recommended GitHub Topics

```
ethereum
solidity
smart-contracts
erc20
token-claim
signature-verification
hardhat
defi
blockchain
web3
openzeppelin
security
cryptography
eip-191
token-distribution
airdrop
```

## 📊 Project Statistics

- **Solidity Version**: 0.8.28
- **OpenZeppelin Version**: 5.0.0
- **Hardhat Version**: 2.24.1
- **License**: MIT
- **Test Coverage**: Comprehensive test suite included

## 🔗 Repository Structure

```
claim_contract/
├── contracts/
│   ├── Claim.sol          # Main claim contract
│   └── MockERC20.sol      # Mock token for testing
├── test/
│   └── Claim.test.js      # Comprehensive test suite
├── script/
│   └── deployClaim.js     # Deployment script
├── hardhat.config.js      # Hardhat configuration
├── package.json           # Dependencies and scripts
└── README.md              # Project documentation
```

## 🚀 Quick Start Commands

```bash
# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm test

# Deploy to Sepolia testnet
npm run deploy:sepolia

# Deploy to Mainnet
npm run deploy:mainnet
```

## 📋 Environment Variables Required

- `PRIVATE_KEY`: Deployer wallet private key
- `INFURA_PROJECT_ID`: Infura RPC endpoint
- `ETHERSCAN_API_KEY`: For contract verification
- `TOKEN_CONTRACT`: ERC20 token address
- `BACKEND_WALLET`: Wallet address that signs claim messages

## 🔐 Security Highlights

- ✅ ReentrancyGuard protection
- ✅ SafeERC20 for token transfers
- ✅ Signature verification using EIP-191
- ✅ Zero address validation
- ✅ Access control with Ownable
- ✅ Comprehensive test coverage

## 📞 Contact

**Telegram**: [@moooncity](https://t.me/moooncity)

---

*This project has been modernized and updated to use the latest OpenZeppelin patterns and best practices.*

