// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Claim is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The ERC20 token to be transferred
    IERC20 public token;

    // Backend wallet address that signs the messages
    address public backendWallet;

    // Track if a signed message has been used (to prevent reuse of same signature)
    mapping(bytes32 => bool) public usedSignatures;

    // Events
    event TokensClaimed(
        address indexed recipient,
        uint256 amount,
        bytes32 indexed messageHash
    );
    event BackendWalletUpdated(
        address indexed oldWallet,
        address indexed newWallet
    );

    event TokenAddressUpdated(
        address indexed oldToken,
        address indexed newToken
    );

    // Signed message structure
    struct ClaimData {
        address recipient;
        uint256 amount;
        uint256 nonce;
        uint256 deadline;
    }

    constructor(address _token, address _backendWallet) {
        require(_token != address(0), "Invalid token address");
        require(_backendWallet != address(0), "Invalid backend wallet address");

        token = IERC20(_token);
        backendWallet = _backendWallet;
    }

    /**
     * @dev Claim tokens based on backend signature
     * @param amount Amount to claim
     * @param nonce Unique nonce for this claim
     * @param deadline Signature expiration timestamp
     * @param signature Backend signature
     */
    function claimTokens(
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes memory signature
    ) external nonReentrant {
        require(block.timestamp <= deadline, "Signature expired");
