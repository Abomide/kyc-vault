# KYC Vault Smart Contract

A Clarity smart contract implementing a collateralized lending vault with KYC requirements on the Stacks blockchain.

## Features

- **Collateral Management**: Users can deposit and withdraw collateral tokens
- **Loan Operations**: Borrow against collateral and repay loans
- **Liquidation System**: Automatic liquidation of undercollateralized positions
- **SIP010 Compatible**: Works with any SIP010-compliant token
- **Price Oracle Integration**: Uses price feeds for collateral valuation

## Contract Constants

```clarity
MIN_COLLATERAL_RATIO: 150%
LIQUIDATION_THRESHOLD: 110%
```

## Error Codes

| Code | Description |
|------|-------------|
| `ERR-NOT-AUTHORIZED` | Unauthorized operation attempt |
| `ERR-TRANSFER-FAILED` | Token transfer failed |
| `ERR-INSUFFICIENT-COLLATERAL` | Insufficient collateral for operation |
| `ERR-NO-LOAN` | No active loan found |
| `ERR-NO-COLLATERAL` | No collateral found |
| `ERR-INVALID-AMOUNT` | Invalid amount specified |
| `ERR-NOT-LIQUIDATABLE` | Position not eligible for liquidation |

## Public Functions

### `deposit-collateral`
```clarity
(deposit-collateral (token-trait <sip010-trait>) (amount uint))
```
Deposit collateral tokens into the vault.

### `repay`
```clarity
(repay (loan-token <sip010-trait>) (amount uint))
```
Repay an existing loan.

### `liquidate`
```clarity
(liquidate (user principal) (loan-token <sip010-trait>) (collateral-token <sip010-trait>))
```
Liquidate an undercollateralized position.

## Read-Only Functions

### `get-user-status`
```clarity
(get-user-status (user principal))
```
Returns user's current collateral and loan status.

## Development

### Prerequisites
- Clarity CLI
- Node.js
- Stacks Blockchain API

### Testing
```bash
clarinet test
```



## Security

This contract is provided as-is. Please conduct thorough security audits before any production use
