// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title TokenSwap - A liquidity pool-based token swap program
/// @notice This contract allows users to create liquidity pools, add/remove liquidity, and swap tokens.
contract TokenSwap is Ownable {
    struct LiquidityPool {
        address tokenA; // Address of token A
        address tokenB; // Address of token B
        uint256 totalLiquidity; // Total liquidity in the pool
        uint256 feePercentage; // Fee percentage for swaps
        address adminFeeAccount; // Account for collecting admin fees
        uint256 lastDepositTime; // Timestamp of the last deposit
    }

    mapping(address => LiquidityPool) public pools;

    event PoolInitialized(
        address indexed pool,
        address indexed tokenA,
        address indexed tokenB,
        uint256 feePercentage
    );
    event LiquidityAdded(address indexed pool, address indexed user, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed pool, address indexed user, uint256 amountA, uint256 amountB);
    event TokensSwapped(
        address indexed pool,
        address indexed user,
        address inputToken,
        address outputToken,
        uint256 amountIn,
        uint256 amountOut
    );

    /// @notice Constructor for the TokenSwap contract
    constructor() Ownable(msg.sender) {}

    /// @notice Initializes a new liquidity pool
    /// @param poolAddress The address of the liquidity pool
    /// @param tokenA Address of token A
    /// @param tokenB Address of token B
    /// @param feePercentage Fee percentage for swaps
    /// @param adminFeeAccount Address to collect admin fees
    function initializePool(
        address poolAddress,
        address tokenA,
        address tokenB,
        uint256 feePercentage,
        address adminFeeAccount
    ) external onlyOwner {
        require(feePercentage <= 1000, "Fee percentage too high");
        require(pools[poolAddress].tokenA == address(0), "Pool already exists");

        pools[poolAddress] = LiquidityPool({
            tokenA: tokenA,
            tokenB: tokenB,
            totalLiquidity: 0,
            feePercentage: feePercentage,
            adminFeeAccount: adminFeeAccount,
            lastDepositTime: block.timestamp
        });

        emit PoolInitialized(poolAddress, tokenA, tokenB, feePercentage);
    }

    /// @notice Adds liquidity to the pool
    /// @param poolAddress The address of the liquidity pool
    /// @param amountA Amount of token A to deposit
    /// @param amountB Amount of token B to deposit
    function addLiquidity(
        address poolAddress,
        uint256 amountA,
        uint256 amountB
    ) external {
        LiquidityPool storage pool = pools[poolAddress];
        require(pool.tokenA != address(0), "Pool does not exist");

        IERC20(pool.tokenA).transferFrom(msg.sender, poolAddress, amountA);
        IERC20(pool.tokenB).transferFrom(msg.sender, poolAddress, amountB);

        uint256 shares = pool.totalLiquidity == 0
            ? amountA + amountB
            : (amountA + amountB) * pool.totalLiquidity / (amountA + amountB);

        pool.totalLiquidity += shares;
        pool.lastDepositTime = block.timestamp;

        emit LiquidityAdded(poolAddress, msg.sender, amountA, amountB);
    }

    /// @notice Removes liquidity from the pool
    /// @param poolAddress The address of the liquidity pool
    /// @param shares The number of liquidity shares to redeem
    function removeLiquidity(
        address poolAddress,
        uint256 shares
    ) external {
        LiquidityPool storage pool = pools[poolAddress];
        require(pool.tokenA != address(0), "Pool does not exist");
        require(block.timestamp >= pool.lastDepositTime + 300, "Withdrawal too soon");

        uint256 proportion = shares * 1e18 / pool.totalLiquidity;
        uint256 amountA = proportion * IERC20(pool.tokenA).balanceOf(poolAddress) / 1e18;
        uint256 amountB = proportion * IERC20(pool.tokenB).balanceOf(poolAddress) / 1e18;

        pool.totalLiquidity -= shares;

        IERC20(pool.tokenA).transfer(msg.sender, amountA);
        IERC20(pool.tokenB).transfer(msg.sender, amountB);

        emit LiquidityRemoved(poolAddress, msg.sender, amountA, amountB);
    }

    /// @notice Swaps one token for another in the pool
    /// @param poolAddress The address of the liquidity pool
    /// @param inputToken Address of the token to swap
    /// @param amountIn Amount of input tokens
    /// @param minOut Minimum acceptable output tokens
    function swap(
        address poolAddress,
        address inputToken,
        uint256 amountIn,
        uint256 minOut
    ) external {
        LiquidityPool storage pool = pools[poolAddress];
        require(pool.tokenA != address(0), "Pool does not exist");
        require(inputToken == pool.tokenA || inputToken == pool.tokenB, "Invalid input token");

        address outputToken = inputToken == pool.tokenA ? pool.tokenB : pool.tokenA;
        uint256 inputBalance = IERC20(inputToken).balanceOf(poolAddress);
        uint256 outputBalance = IERC20(outputToken).balanceOf(poolAddress);

        uint256 amountOut = (amountIn * outputBalance) / (inputBalance + amountIn);
        uint256 fee = (amountOut * pool.feePercentage) / 10000;
        amountOut -= fee;

        require(amountOut >= minOut, "Insufficient output amount");

        IERC20(inputToken).transferFrom(msg.sender, poolAddress, amountIn);
        IERC20(outputToken).transfer(msg.sender, amountOut);
        IERC20(outputToken).transfer(pool.adminFeeAccount, fee);

        emit TokensSwapped(poolAddress, msg.sender, inputToken, outputToken, amountIn, amountOut);
    }
}
