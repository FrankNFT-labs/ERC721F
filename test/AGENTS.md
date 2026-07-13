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
│   ├── tooling/
│   ├── utils/
│   └── token/
│       ├── ERC721/
│       │   └── extensions/
│       └── soulbound/
└── foundry/
    ├── examples/
    ├── utils/
    └── token/
        ├── ERC721/
        │   └── extensions/
        └── soulbound/
```

## WHERE TO LOOK

| Need                            | Location                                               | Notes                                 |
| ------------------------------- | ------------------------------------------------------ | ------------------------------------- |
| Core ERC721 behavior (JS)       | `hardhat/token/ERC721/*.test.js`                       | hardhat assertion layer               |
| Shared hardhat behavior helpers | `hardhat/behaviours/`                                  | reusable test behavior modules        |
| Soulbound-specific coverage     | `hardhat/token/soulbound/`, `foundry/token/soulbound/` | transfer-lock semantics + gas anchors |
| Utility contract coverage       | `hardhat/utils/`, `foundry/utils/`                     | allowlists, payable, address utils    |
| Gas/break-even solidity tests   | `foundry/token/ERC721/*.t.sol`                         | forge-native metrics                  |
| Example-contract foundry checks | `foundry/examples/`                                    | example integration validation        |

## CONVENTIONS

- Hardhat selection: `npx hardhat test test/hardhat/<path>.test.js`.
- Foundry selection: `forge test --match-path "test/foundry/..."`.
- Gas reporting: `npx hardhat test --gas-stats` (Hardhat 3 built-in) or `forge test --gas-report` (Foundry-native).
- Hardhat tests are ESM and share one network connection via `test/hardhat/helpers/connection.js`.

## ANTI-PATTERNS

- Updating contract behavior and validating only one framework.
- Using incorrect hardhat test paths (tests are under `test/hardhat/`, not `test/token/`).
- Treating `lib/forge-std` as first-party test code (vendored dependency).
