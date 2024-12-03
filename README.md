# TokenSwap


## Overview
This project is a decentralized liquidity pool-based token swap contract built on Ethereum. It allows users to:

- Create liquidity pools for token pairs.
- Add and remove liquidity from the pools.
- Swap one token for another within the liquidity pool.
- Earn fees from swaps as a liquidity provider.

This contract is implemented using Solidity and relies on the ERC20 token standard. It is designed to be tested and deployed using Remix IDE.

## Features

### Liquidity Pools
- Users can initialize pools for two ERC20 tokens.
- Pools track the total liquidity and manage swap fees.
- Admin fees can be directed to a specific account.

### Adding Liquidity
- Users can deposit two tokens in the correct ratio.
- Liquidity providers earn proportional shares of the pool.

### Removing Liquidity
- Liquidity providers can redeem their shares for the underlying tokens.
- Withdrawals are time-locked to prevent immediate removal after deposit.

### Swapping Tokens
- Allows swapping one token for another within a pool.
- Implements a fee for each swap, distributed to the pool and admin.

### Fee Management
- Swap fees are calculated as a percentage of the output tokens.
- Admin fees are sent to a designated address.

## Smart Contract Details

### Contract: TokenSwap

### Functions:
- **initializePool**: Sets up a new liquidity pool.
- **addLiquidity**: Allows users to add liquidity to a pool.
- **removeLiquidity**: Allows users to remove liquidity after a time lock.
- **swap**: Swaps one token for another within the pool.

### Events:
- **PoolInitialized**: Emitted when a new pool is created.
- **LiquidityAdded**: Emitted when liquidity is added to a pool.
- **LiquidityRemoved**: Emitted when liquidity is removed from a pool.
- **TokensSwapped**: Emitted when tokens are swapped.

### Structs:
- **LiquidityPool**: Stores details about each pool, such as tokens, fees, and total liquidity.
