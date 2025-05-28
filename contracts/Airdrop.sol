// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Airdrop is Ownable, ReentrancyGuard {
    // The ERC20 token to be transferred
    IERC20 public token;

    // Backend wallet address that signs the messages
    address public backendWallet;

    // Vesting schedule starts at UTC 3 PM tomorrow
    uint256 public vestingStartTime;

    // 1 week in seconds
    uint256 public constant WEEK_DURATION = 7 days;
    // Track claimed amounts for each user's signed message
    // user => messageHash => claimedAmount
    mapping(address => mapping(bytes32 => uint256)) public claimedAmounts;

    // Track if a signed message has been used (to prevent reuse of same signature)
    mapping(bytes32 => bool) public usedSignatures;

    // Events
    event AirdroppedTokens(
        address indexed recipient,
        uint256 amount,
        uint256 totalClaimed,
        uint256 week,
        bytes32 indexed messageHash
    );
    event VestingStartTimeUpdated(uint256 newStartTime);
    event BackendWalletUpdated(
        address indexed oldWallet,
        address indexed newWallet
    );
event LogAddress(string label, address addr);
    // Signed message structure
    struct ClaimData {
        address recipient;
        uint256 totalAmount;
        uint256 nonce;
        uint256 deadline;
    }

    constructor(
        address _token,
        address _backendWallet,
        uint256 _vestingStartTime
    ) {
        require(_token != address(0), "Invalid token address");
        require(_backendWallet != address(0), "Invalid backend wallet address");
        //require(_vestingStartTime > block.timestamp, "Vesting start time must be in future");

        token = IERC20(_token);
        backendWallet = _backendWallet;
        vestingStartTime = _vestingStartTime;
    }

    /**
     * @dev Claim vested tokens based on backend signature
     * @param totalAmount Total amount that can be claimed over 4 weeks
     * @param nonce Unique nonce for this allocation
     * @param deadline Signature expiration timestamp
     * @param signature Backend signature
     */
    function airdropTokens(
        uint256 totalAmount,
        uint256 nonce,
        uint256 deadline,
        bytes memory signature
    ) external nonReentrant {
        require(
            block.timestamp >= vestingStartTime,
            "Vesting has not started yet"
        );
        require(block.timestamp <= deadline, "Signature expired");
        require(totalAmount > 0, "Total amount must be greater than 0");

        // Create claim data
        ClaimData memory claimData = ClaimData({
            recipient: msg.sender,
            totalAmount: totalAmount,
            nonce: nonce,
            deadline: deadline
        });

        // Verify signature
        bytes32 messageHash = _getMessageHash(claimData);
        require(_verifySignature(messageHash, signature), "Invalid signature");

        // Prevent reuse of the same signature
        require(!usedSignatures[messageHash], "Signature already used");

        // Calculate how much can be claimed now
        uint256 availableAmount = _calculateAvailableAmount(totalAmount);
        uint256 alreadyClaimed = claimedAmounts[msg.sender][messageHash];

        require(
            availableAmount > alreadyClaimed,
            "No tokens available to claim"
        );

        uint256 claimableAmount = availableAmount - alreadyClaimed;

        // Update claimed amount
        claimedAmounts[msg.sender][messageHash] = availableAmount;

        // Mark signature as used if fully claimed
        if (availableAmount == totalAmount) {
            usedSignatures[messageHash] = true;
        }

        // Check contract has enough tokens
        require(
            token.balanceOf(address(this)) >= claimableAmount,
            "Insufficient contract balance"
        );

        // Transfer tokens
        require(
            token.transfer(msg.sender, claimableAmount),
            "Token transfer failed"
        );

        // Calculate current week for event
        uint256 currentWeek = (block.timestamp - vestingStartTime) /
            WEEK_DURATION;

        emit AirdroppedTokens(
            msg.sender,
            claimableAmount,
            availableAmount,
            currentWeek,
            messageHash
        );
    }

    /**
     * @dev Calculate how much tokens are available to claim based on vesting schedule
     * @param totalAmount Total amount allocated to user
     * @return uint256 Amount available to claim
     */
    function _calculateAvailableAmount(
        uint256 totalAmount
    ) internal view returns (uint256) {
        if (block.timestamp < vestingStartTime) {
            return 0;
        }

        uint256 quarterAmount = totalAmount / 4;
        uint256 timeElapsed = block.timestamp - vestingStartTime;
        uint256 weeksElapsed = timeElapsed / WEEK_DURATION;

        // Cap at 4 weeks (100% vested)
        if (weeksElapsed >= 4) {
            return totalAmount;
        }

        // Calculate available amount based on weeks elapsed
        // Week 0: 1/4, Week 1: 2/4, Week 2: 3/4, Week 3+: 4/4
        return quarterAmount * (weeksElapsed + 1);
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
                    claimData.totalAmount,
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
    ) internal  returns (bool) {
        // Create Ethereum signed message hash
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        // Recover signer from signature
        address recoveredSigner = _recoverSigner(
            ethSignedMessageHash,
            signature
        );
        // Emit the addresses to see their values
        emit LogAddress("Recovered Signer", recoveredSigner);
        emit LogAddress("Backend Wallet", backendWallet);
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
     * @dev Get claimable amount for a user with given parameters
     * @param user User address
     * @param totalAmount Total amount in the signed message
     * @param nonce Nonce from signed message
     * @param deadline Deadline from signed message
     * @return claimableNow Amount that can be claimed right now
     * @return totalClaimed Amount already claimed
     * @return totalAvailable Total amount available based on vesting schedule
     */
    function getClaimableAmount(
        address user,
        uint256 totalAmount,
        uint256 nonce,
        uint256 deadline
    )
        external
        view
        returns (
            uint256 claimableNow,
            uint256 totalClaimed,
            uint256 totalAvailable
        )
    {
        ClaimData memory claimData = ClaimData({
            recipient: user,
            totalAmount: totalAmount,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 messageHash = _getMessageHash(claimData);
        totalClaimed = claimedAmounts[user][messageHash];
        totalAvailable = _calculateAvailableAmount(totalAmount);

        if (totalAvailable > totalClaimed) {
            claimableNow = totalAvailable - totalClaimed;
        } else {
            claimableNow = 0;
        }
    }

    /**
     * @dev Get current vesting week (0-based)
     * @return uint256 Current week number
     */
    function getCurrentWeek() external view returns (uint256) {
        if (block.timestamp < vestingStartTime) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - vestingStartTime;
        return timeElapsed / WEEK_DURATION;
    }

    /**
     * @dev Check if a signature has been fully used
     * @param recipient Recipient address
     * @param totalAmount Total amount
     * @param nonce Nonce
     * @param deadline Deadline
     * @return bool True if signature is fully used
     */
    function isSignatureUsed(
        address recipient,
        uint256 totalAmount,
        uint256 nonce,
        uint256 deadline
    ) external view returns (bool) {
        ClaimData memory claimData = ClaimData({
            recipient: recipient,
            totalAmount: totalAmount,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 messageHash = _getMessageHash(claimData);
        return usedSignatures[messageHash];
    }

    /**
     * @dev Verify a signature without executing (for testing)
     * @param recipient Recipient address
     * @param totalAmount Total amount
     * @param nonce Nonce
     * @param deadline Deadline
     * @param signature Signature to verify
     * @return bool True if signature is valid
     */
    function verifySignature(
        address recipient,
        uint256 totalAmount,
        uint256 nonce,
        uint256 deadline,
        bytes memory signature
    ) external  returns (bool) {
        ClaimData memory claimData = ClaimData({
            recipient: recipient,
            totalAmount: totalAmount,
            nonce: nonce,
            deadline: deadline
        });

        bytes32 messageHash = _getMessageHash(claimData);
        return _verifySignature(messageHash, signature);
    }

    // Admin functions

    /**
     * @dev Update vesting start time (only before vesting starts)
     * @param _newStartTime New start time
     */
    function updateVestingStartTime(uint256 _newStartTime) external onlyOwner {
        require(block.timestamp < vestingStartTime, "Vesting already started");
        require(
            _newStartTime > block.timestamp,
            "Start time must be in future"
        );

        vestingStartTime = _newStartTime;
        emit VestingStartTimeUpdated(_newStartTime);
    }

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
