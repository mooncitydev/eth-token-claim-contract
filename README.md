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
