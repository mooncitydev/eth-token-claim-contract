// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Claim is Ownable, ReentrancyGuard {
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

    // Signed message structure
    struct ClaimData {
        address recipient;
        uint256 amount;
        uint256 nonce;
        uint256 deadline;
    }

    constructor(
        address _token,
        address _backendWallet
    ) {
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
        require(amount > 0, "Amount must be greater than 0");

        // Create claim data
        ClaimData memory claimData = ClaimData({
            recipient: msg.sender,
            amount: amount,
            nonce: nonce,
            deadline: deadline
        });

        // Verify signature
        bytes32 messageHash = _getMessageHash(claimData);
        require(_verifySignature(messageHash, signature), "Invalid signature");

        // Prevent reuse of the same signature
        require(!usedSignatures[messageHash], "Signature already used");
        usedSignatures[messageHash] = true;

        // Check contract has enough tokens
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient contract balance"
        );

        // Transfer tokens
        require(
            token.transfer(msg.sender, amount),
            "Token transfer failed"
        );

        emit TokensClaimed(msg.sender, amount, messageHash);
    }

    /**
     * @dev Get the hash of the claim data (same as backend)
     * @param claimData The claim data struct
     * @return bytes32 Hash of the claim data
     */
    function _getMessageHash(
        ClaimData memory claimData
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    claimData.recipient,
                    claimData.amount,
                    claimData.nonce,
                    claimData.deadline
                )
            );
    }

    /**
     * @dev Verify the backend signature
     * @param messageHash Hash of the message
     * @param signature The signature to verify
     * @return bool True if signature is valid
     */
    function _verifySignature(
        bytes32 messageHash,
        bytes memory signature
    ) internal view returns (bool) {
        // Create Ethereum signed message hash
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        // Recover signer from signature
        address recoveredSigner = _recoverSigner(
            ethSignedMessageHash,
            signature
        );

        // Verify signer is the backend wallet
        return recoveredSigner == backendWallet;
    }

    /**
     * @dev Recover signer address from signature
     * @param hash The hash that was signed
     * @param signature The signature
     * @return address The recovered signer address
     */
    function _recoverSigner(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return ecrecover(hash, v, r, s);
    }

    // View functions

    /**
     * @dev Check if a signature has been used
     * @param recipient Recipient address
     * @param amount Amount
     * @param nonce Nonce
     * @param deadline Deadline
     * @return bool True if signature is used
     */
    function isSignatureUsed(
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 deadline
    ) external view returns (bool) {
        ClaimData memory claimData = ClaimData({
            recipient: recipient,
            amount: amount,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 messageHash = _getMessageHash(claimData);
        return usedSignatures[messageHash];
    }

    /**
     * @dev Verify a signature without executing (for testing)
     * @param recipient Recipient address
     * @param amount Amount
     * @param nonce Nonce
     * @param deadline Deadline
     * @param signature Signature to verify
     * @return bool True if signature is valid
     */
    function verifySignature(
        address recipient,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes memory signature
    ) external view returns (bool) {
        ClaimData memory claimData = ClaimData({
            recipient: recipient,
            amount: amount,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 messageHash = _getMessageHash(claimData);
        return _verifySignature(messageHash, signature);
    }

    // Admin functions

    /**
     * @dev Update backend wallet address
     * @param _newBackendWallet New backend wallet address
     */
    function updateBackendWallet(address _newBackendWallet) external onlyOwner {
        require(_newBackendWallet != address(0), "Invalid address");

        address oldWallet = backendWallet;
        backendWallet = _newBackendWallet;

        emit BackendWalletUpdated(oldWallet, _newBackendWallet);
    }

    /**
     * @dev Emergency withdraw tokens
     * @param amount Amount to withdraw
     */
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        require(token.transfer(owner(), amount), "Transfer failed");
    }

    /**
     * @dev Get contract token balance
     * @return uint256 Token balance
     */
    function getContractBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}