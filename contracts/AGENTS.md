# AGENTS.md - contracts/

Inherits from `../AGENTS.md`. This file lists contract-subtree specifics only.

## OVERVIEW
First-party production Solidity code (core token, extensions, utilities, interfaces, and mocks used for testing support).

## STRUCTURE
```text
contracts/
├── token/
│   ├── ERC721/
│   │   ├── ERC721F.sol
│   │   ├── ERC721FCOMMON.sol
│   │   └── extensions/
│   └── soulbound/
├── utils/
├── interfaces/
└── mocks/
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| ERC721F supply/accounting | `token/ERC721/ERC721F.sol` | `_update` controls mint/burn counters |
| Royalties/payable base | `token/ERC721/ERC721FCOMMON.sol` | combines ERC721F + ERC2981 + payable helper |
| Enumerable compatibility | `token/ERC721/extensions/ERC721FEnumerable.sol` | O(totalSupply) enumeration tradeoff |
| On-chain metadata pattern | `token/ERC721/extensions/ERC721FOnChain.sol` | IERC4883-driven tokenURI composition |
| Soulbound transfer policy | `token/soulbound/Soulbound.sol` | IERC5192 + IERC6454 logic |
| Access/allowlist utils | `utils/AllowList*.sol`, `utils/*Operable*.sol` | reusable sale-control pieces |
| External-facing interfaces | `interfaces/*.sol` | protocol and utility interfaces |

## CONVENTIONS
- Favor extending `ERC721F` / `ERC721FCOMMON` over copying token accounting logic.
- Preserve gas-oriented loop style (`unchecked` increments) where already used.
- Keep production logic in `token/` and `utils/`; keep test helpers in `mocks/`.

## ANTI-PATTERNS
- Treating `contracts/mocks/*` as deploy-ready production contracts.
- Duplicating existing utility primitives instead of reusing `utils/` modules.
- Modifying supply accounting without matching tests in both hardhat/foundry suites.
