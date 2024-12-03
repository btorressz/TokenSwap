// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./TokenSwap.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title TestToken - Mock ERC20 Token for Testing
contract TestToken is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

/// @title TokenSwapTest - A test contract to test the TokenSwap contract
contract TokenSwapTest {
    TokenSwap public tokenSwap;
    TestToken public tokenA;
    TestToken public tokenB;
    address public poolAddress;
    address public adminFeeAccount;

    constructor() {
        // Deploy TokenSwap
        tokenSwap = new TokenSwap();

        // Deploy mock tokens
        tokenA = new TestToken("Token A", "TKA", 1_000_000 * 10 ** 18);
        tokenB = new TestToken("Token B", "TKB", 1_000_000 * 10 ** 18);

        // Create a mock pool address and admin fee account
        poolAddress = address(this);
        adminFeeAccount = address(0x123);

        // Approve the pool to spend tokens for testing
        tokenA.approve(poolAddress, type(uint256).max);
        tokenB.approve(poolAddress, type(uint256).max);

        // Initialize the pool
        tokenSwap.initializePool(
            poolAddress,
            address(tokenA),
            address(tokenB),
            30, // Fee percentage (0.3%)
            adminFeeAccount
        );
    }

    /// @notice Test adding liquidity
    /// @param amountA Amount of Token A to deposit
    /// @param amountB Amount of Token B to deposit
    function testAddLiquidity(uint256 amountA, uint256 amountB) external {
        // Mint tokens to the caller for testing
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        // Approve the TokenSwap contract to spend tokens
        tokenA.approve(address(tokenSwap), amountA);
        tokenB.approve(address(tokenSwap), amountB);

        // Add liquidity
        tokenSwap.addLiquidity(poolAddress, amountA, amountB);
    }

    /// @notice Test removing liquidity
    /// @param shares Number of shares to redeem
    function testRemoveLiquidity(uint256 shares) external {
        // Remove liquidity
        tokenSwap.removeLiquidity(poolAddress, shares);
    }

    /// @notice Test swapping tokens
    /// @param inputToken Address of the token to swap
    /// @param amountIn Amount of tokens to swap
    /// @param minOut Minimum acceptable output tokens
    function testSwap(
        address inputToken,
        uint256 amountIn,
        uint256 minOut
    ) external {
        // Approve the TokenSwap contract to spend tokens
        IERC20(inputToken).approve(address(tokenSwap), amountIn);

        // Perform the swap
        tokenSwap.swap(poolAddress, inputToken, amountIn, minOut);
    }

    /// @notice Test pool initialization
    function testInitializePool(
        address _poolAddress,
        address _tokenA,
        address _tokenB,
        uint256 _feePercentage,
        address _adminFeeAccount
    ) external {
        tokenSwap.initializePool(_poolAddress, _tokenA, _tokenB, _feePercentage, _adminFeeAccount);
    }
}
