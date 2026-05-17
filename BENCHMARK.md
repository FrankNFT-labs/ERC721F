# ERC721F Gas Benchmark

Measured gas consumption of **ERC721F** compared to **OpenZeppelin ERC721 + ERC721Enumerable** — the canonical "before" implementation that ERC721F replaces.

All figures are Foundry measurements at identical conditions. Hardhat numbers are cross-validated and match.

---

## Environment

| Property       | Value                      |
| -------------- | -------------------------- |
| Solidity       | 0.8.24                     |
| OpenZeppelin   | 5.6.1                      |
| EVM target     | Cancun                     |
| Optimizer      | enabled, 1 000 runs        |
| Foundry        | forge (see `foundry.toml`) |
| Hardhat        | see `hardhat.config.js`    |
| Benchmark date | 2026-05-17                 |

---

## Summary

| Operation                | OZ ERC721Enumerable (avg) | ERC721F (avg) | Gas saved | % saved |
| ------------------------ | ------------------------: | ------------: | --------: | ------: |
| Deploy                   |                 1,358,592 |     1,499,543 |  -140,951 |    −10% |
| Mint 1                   |                   129,760 |        82,606 |    47,154 | **36%** |
| Mint 10 (total)          |                 1,157,600 |       313,270 |   844,330 | **73%** |
| Mint 100 (total)         |                11,459,768 |     2,592,115 | 8,867,653 | **77%** |
| Transfer 1 (wallet 1)    |                    71,538 |        58,719 |    12,819 | **18%** |
| Transfer 10 (wallet 10)  |                   436,725 |       177,868 |   258,857 | **59%** |
| Transfer 50 (wallet 100) |                 2,086,404 |     1,062,229 | 1,024,175 | **49%** |

> **Deploy cost** is the one area where ERC721F is slightly heavier (+10%). The extra bytecode comes from
> `walletOfOwner` and the internal supply-counter logic. This is a one-time cost and negligible at scale.

---

## Mint Gas — Detailed

| Operation     |     OZ min |     OZ avg |     OZ max | ERC721F min | ERC721F avg | ERC721F max |
| ------------- | ---------: | ---------: | ---------: | ----------: | ----------: | ----------: |
| `mintOne`     |    122,685 |    129,760 |    150,985 |      56,956 |      82,606 |      91,156 |
| `mintTen`     |  1,152,884 |  1,157,600 |  1,181,184 |     284,770 |     313,270 |     318,970 |
| `mintHundred` | 11,455,052 | 11,459,768 | 11,483,352 |   2,563,615 |   2,592,115 |   2,597,815 |

**Per-token cost (avg):**

| Batch size | OZ per token | ERC721F per token | Savings per token |
| ---------: | -----------: | ----------------: | ----------------: |
|          1 |      129,760 |            82,606 |            47,154 |
|         10 |      115,760 |            31,327 |            84,433 |
|        100 |      114,598 |            25,921 |            88,677 |

The per-token cost of ERC721F **decreases** toward ~25 k gas as batch size grows because the storage slot
warm-up is amortized. OZ ERC721Enumerable stays flat at ~115 k per token due to the three mapping writes
it requires per mint (`_allTokens`, `_ownedTokens`, `_ownedTokensIndex`).

---

## Transfer Gas — Detailed

Transfer helpers explanation:

- **Asc** = transfers the token with the lowest ID in the wallet (`tokenId 0` direction)
- **Desc** = transfers the token with the highest ID in the wallet (`last tokenId` direction)
- **Wallet size** = how many tokens the sender holds at the time of transfer

OZ uses `tokenOfOwnerByIndex()` (O(1) index lookup) for its transfer helpers.
ERC721F uses `retrieveFirstToken()` / `retrieveLastToken()` which scan the supply linearly (O(totalMinted)).
**ERC721F still wins despite this scan overhead** because OZ Enumerable must update three storage
mappings on every transfer whereas ERC721F's transfer touches only the base ERC721 ownership slot.

| Operation                       |    OZ min |    OZ avg |    OZ max | ERC721F min | ERC721F avg | ERC721F max |
| ------------------------------- | --------: | --------: | --------: | ----------: | ----------: | ----------: |
| Transfer 1 — wallet 1 (asc)     |    63,103 |    71,538 |    88,409 |      57,119 |      58,719 |      61,919 |
| Transfer 1 — wallet 1 (desc)    |    63,446 |    70,346 |    84,146 |      57,059 |      58,659 |      61,859 |
| Transfer 1 — wallet 10 (asc)    |         — |         — |         — |           — |           — |           — |
| Transfer 1 — wallet 10 (desc)   |         — |         — |         — |           — |           — |           — |
| Transfer 10 — wallet 10 (asc)   |   427,357 |   436,725 |   455,463 |     176,268 |     177,868 |     181,068 |
| Transfer 10 — wallet 10 (desc)  |   442,502 |   444,368 |   448,102 |     175,072 |     176,672 |     179,872 |
| Transfer 10 — wallet 100 (asc)  |         — |         — |         — |           — |           — |           — |
| Transfer 10 — wallet 100 (desc) |         — |         — |         — |           — |           — |           — |
| Transfer 50 — wallet 100 (asc)  | 2,086,404 | 2,086,404 | 2,086,404 |   1,062,229 |   1,062,229 |   1,062,229 |
| Transfer 50 — wallet 100 (desc) | 2,065,548 | 2,065,548 | 2,065,548 |   1,033,264 |   1,033,264 |   1,033,264 |

> "—" means the test variant exists in one suite but has no counterpart in the other (not included in total
> gas figures above).

---

## Break-Even Analysis

`BreakEven.t.sol` transfers all 100 tokens from a 100-token wallet sequentially (configurable via
`BREAK_EVEN_COUNT` env var, defaults to 100).

| Operation                        | ERC721F total gas |
| -------------------------------- | ----------------: |
| Mint 100 + transfer all 100 asc  |         5,574,668 |
| Mint 100 + transfer all 100 desc |         5,459,230 |

Transferring in **descending order (highest token ID first)** is consistently ~2% cheaper because
`retrieveLastToken()` exits earlier in the scan once high-range tokens are transferred away.

---

## Deployment Cost

| Contract                          | Deploy gas | Bytecode size |
| --------------------------------- | ---------: | ------------: |
| OZErc721EnumerableGasReporterMock |  1,358,592 |         6,719 |
| ERC721FGasReporterMock            |  1,499,543 |         7,389 |

ERC721F is ~10% heavier to deploy. This is a fixed, one-time cost per collection launch. At any
meaningful mint volume the per-mint savings recoup the extra deploy gas within the first ~2 mints.

---

## Key Design Trade-offs

| Aspect                            | OZ ERC721Enumerable      | ERC721F                              |
| --------------------------------- | ------------------------ | ------------------------------------ |
| Mint storage writes               | 3 per token (3 mappings) | 1 per token (owner only)             |
| Transfer storage writes           | 3 per token (3 mappings) | 1 per token (owner only)             |
| `totalSupply()`                   | O(1)                     | O(1) (`_tokenSupply - _burnCounter`) |
| `walletOfOwner()`                 | O(balance) via index     | O(totalMinted) linear scan           |
| Token enumeration                 | O(1) index lookup        | Not natively indexed                 |
| Deploy cost                       | Lower                    | ~10% higher                          |
| Suitable for on-chain enumeration | Yes                      | No — off-chain / view only           |

> `walletOfOwner()` in ERC721F is designed for off-chain use (e.g., dapp frontends calling via
> `eth_call`). **Do not call it from another contract on-chain** — it will be expensive at scale.

---

## How to Replicate

### Prerequisites

```bash
# Node.js >= 18
npm install

# Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Foundry — ERC721F benchmarks

```bash
# All gas tests + report
forge test --gas-report --match-path "test/foundry/token/ERC721/ERC721FGasReporterMock.t.sol"

# Mint only
forge test --gas-report --match-contract "ERC721FGasReporterMockTest" --mt "testMint"

# Transfer only
forge test --gas-report --match-contract "ERC721FGasReporterMockTest" --mt "testTransfer"

# Break-even (default 100 transfers)
forge test --gas-report --match-path "test/foundry/token/ERC721/BreakEven.t.sol"

# Break-even with custom transfer count
BREAK_EVEN_COUNT=50 forge test --gas-report --match-path "test/foundry/token/ERC721/BreakEven.t.sol"
```

### Foundry — OZ ERC721Enumerable comparison

```bash
forge test --gas-report --match-path "test/foundry/token/ERC721/OZErc721GasComparison.t.sol"
```

### Foundry — both side by side

```bash
forge test --gas-report \
  --match-path "test/foundry/token/ERC721/ERC721FGasReporterMock.t.sol" \
  --match-path "test/foundry/token/ERC721/OZErc721GasComparison.t.sol"
```

> Note: `--match-path` only accepts one path at a time in Foundry. Run both commands separately and
> compare the two `╭─…─╮` tables.

### Hardhat — ERC721F gas report

```bash
# Enable gas reporting (set in .env or inline)
REPORT_GAS=true npx hardhat test ./test/hardhat/token/ERC721/GasUsage.test.js
```

To write the report to a file, uncomment `outputFile` in `hardhat.config.js` under `gasReporter`.

### Changing the optimizer runs

Edit `hardhat.config.js`:

```js
solidity: {
  optimizer: {
    enabled: true,
    runs: 1000   // ← change this; higher = cheaper runtime, more expensive deploy
  }
}
```

And `foundry.toml`:

```toml
[profile.default]
optimizer = true
optimizer_runs = 1000   # ← same here
```

### Relevant source files

| File                                                     | Purpose                     |
| -------------------------------------------------------- | --------------------------- |
| `contracts/mocks/ERC721FGasReporterMock.sol`             | ERC721F stress contract     |
| `contracts/mocks/OZErc721EnumerableGasReporterMock.sol`  | OZ baseline stress contract |
| `test/foundry/token/ERC721/ERC721FGasReporterMock.t.sol` | Foundry ERC721F tests       |
| `test/foundry/token/ERC721/OZErc721GasComparison.t.sol`  | Foundry OZ comparison tests |
| `test/foundry/token/ERC721/BreakEven.t.sol`              | Break-even analysis         |
| `test/hardhat/token/ERC721/GasUsage.test.js`             | Hardhat cross-validation    |
