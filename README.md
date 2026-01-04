# MiCAR-aware Stablecoin System (Proof-of-Concept)

**Author:** Saeed Rafay

This is a compact, leadership-focused artifact that shows how I would design a EUR-backed stablecoin for the EU market while prioritising compliance, custody separation, operational safety and sensible engineering trade-offs.

> ⚠️ This is a conceptual artifact and learning repo. Do **not** use the contract in production without professional security reviews, legal sign-off, and full operational controls.


## Executive summary

I designed a conservative stablecoin architecture that keeps regulatory realities front and centre (MiCA-era expectations), separates issuance from custody, and makes transparency and recoverability first-class. The goal is to show principled engineering and product judgement: how I would *design* a compliant product (not launch a live token in this repo).

Key signals this artifact communicates:
- operational custody vs issuance separation
- on-chain/off-chain boundary handling
- redemption and reserve accounting flows
- governance, audits, and emergency controls


## What's in this repository

### Smart Contracts
- `contracts/SimpleStablecoin.sol` — Minimal ERC-20 token that supports issuance/redemption signalling, privileged mint/burn, and pause controls.

### Tests
- `test/SimpleStablecoin.test.ts` — TypeScript test suite (Mocha + Chai + Ethers.js v6)
- `contracts/SimpleStablecoin.t.sol` — Solidity test suite with fuzzing capabilities

### Documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) — Detailed system design with Mermaid diagrams describing on-chain/off-chain interactions, trust boundaries, and component responsibilities.
- [GOVERNANCE.md](GOVERNANCE.md) — Operational framework covering legal structure, reserves, KYC/AML, emergency controls, and compliance considerations for regulated stablecoin operations.


## Design assumptions & constraints

- This design targets EU markets and is *MiCAR-aware*, not MiCAR-certified. It assumes the user(s) intends to comply with stablecoin-specific regulation in the EU.  
- I do **not** build a money market, lending, or fractional reserve system here. Reserves are intended to be fully-backed and attested.
- No on-chain or off-chain financial advice is offered. This is an engineering & product design artifact only.


## Design goals & non-goals

**Goals**
- Separate issuance and custody responsibilities between legal entities.
- Ensure fiat is always settled off-chain before on-chain minting (signalling + operator-driven mint).
- Prioritize auditable, explainable flows: events, immutable issuance/redemption records.
- Provide circuit-breakers (pause) and privilege separation for safe operations.


**Non-goals**
- No yield or fractional reserve mechanics.
- No on-chain algorithmic peg or automated market-making.
- No permissionless minting or complex DeFi integrations.
- Not intended as legal/regulatory advice or production code.


## Quick architecture (happy path)

1. User completes KYC and deposits EUR with a custodian bank.
2. Custodian/Issuer records fiat settlement off-chain.
3. Issuer (off-chain operator) calls `mintFor(user, amount)` to finalize on-chain issuance.
4. User transfers tokens on-chain. For redemption, the user calls `requestRedemption(amount, ref)`; issuer verifies and then calls `burnFromIssuer(user, amount)` after fiat transfer.

> 📖 For detailed architecture with diagrams and component descriptions, see [ARCHITECTURE.md](ARCHITECTURE.md)  
> 📖 For governance, compliance, and operational controls, see [GOVERNANCE.md](GOVERNANCE.md)


## Key technical features

- **Privileged minting/burning**: Only authorized issuer or owner can mint/burn tokens
- **Event-driven workflow**: Issuance and redemption requests emit events for off-chain monitoring
- **Emergency controls**: Owner can pause all operations (minting, burning, redemption requests)
- **Role separation**: Distinct owner and issuer roles for governance flexibility
- **ERC-20 compliant**: Standard token interface for wallet and DeFi compatibility


## Development setup

### Prerequisites
- Node.js 18+ and npm

### Installation

```bash
npm install
```

### Running tests

```bash
npx hardhat test
```

This runs both TypeScript (Mocha/Chai) and Solidity test suites.


## Project structure

```
contracts/              # Solidity smart contracts
  SimpleStablecoin.sol  # Main stablecoin contract
  SimpleStablecoin.t.sol # Foundry test suite
test/                   # Hardhat test suite
  SimpleStablecoin.test.ts
types/                  # TypeScript type definitions (auto-generated)
artifacts/              # Compiled contract artifacts
ARCHITECTURE.md         # System design documentation
GOVERNANCE.md           # Operational and compliance framework
```
