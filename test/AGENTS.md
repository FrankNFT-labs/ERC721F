# AGENTS.md - test/

Inherits from `../AGENTS.md`. This file lists test-subtree specifics only.

## OVERVIEW
Dual-framework test suite: Hardhat JS tests and Foundry Solidity tests are intentionally separate and both are relevant.

## STRUCTURE
```text
test/
├── hardhat/
│   ├── behaviours/
│   ├── examples/
│   └── token/
│       ├── ERC721/
│       └── soulbound/
└── foundry/
    ├── examples/
    └── token/
        └── ERC721/
```

## WHERE TO LOOK
| Need | Location | Notes |
|------|----------|-------|
| Core ERC721 behavior (JS) | `hardhat/token/ERC721/*.test.js` | hardhat assertion layer |
| Shared hardhat behavior helpers | `hardhat/behaviours/` | reusable test behavior modules |
| Soulbound-specific coverage | `hardhat/token/soulbound/` | transfer-lock semantics |
| Gas/break-even solidity tests | `foundry/token/ERC721/*.t.sol` | forge-native metrics |
| Example-contract foundry checks | `foundry/examples/` | example integration validation |

## CONVENTIONS
- Hardhat selection: `WHITELIST_CONTRACT=<Name> npx hardhat test`.
- Foundry selection: `forge test --match-path "test/foundry/..."`.
- Gas reporting paths are framework-specific (`REPORT_GAS=true` vs `forge --gas-report`).

## ANTI-PATTERNS
- Updating contract behavior and validating only one framework.
- Using incorrect hardhat test paths (tests are under `test/hardhat/`, not `test/token/`).
- Treating `lib/forge-std` as first-party test code (vendored dependency).
