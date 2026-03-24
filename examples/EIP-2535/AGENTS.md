# AGENTS.md - examples/EIP-2535/

Inherits from `../AGENTS.md`. This file lists EIP-2535 workspace specifics only.

## OVERVIEW
Isolated Diamond Standard workspace with its own package/config, contracts, deploy scripts, and tests.

## STRUCTURE
```text
examples/EIP-2535/
├── contracts/
│   ├── ERC721F/
│   │   ├── ERC721FStorage.sol
│   │   ├── ERC721FUpgradeable.sol
│   │   ├── ERC721FUpgradeableInternal.sol
│   │   └── IERC721Upgradeable.sol
│   ├── InitFacet.sol
│   ├── MintFacet.sol
│   ├── SaleControl.sol
│   └── WithStorage.sol
├── deploy/
├── test/
├── hardhat.config.js
└── package.json
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Diamond storage shape | `contracts/ERC721F/ERC721FStorage.sol` | storage compatibility anchor |
| Upgradeable ERC721 behavior | `contracts/ERC721F/ERC721FUpgradeable*.sol` | workspace-specific variant |
| Facet initialization/mint flow | `contracts/InitFacet.sol`, `contracts/MintFacet.sol` | facet split responsibilities |
| Sale controls | `contracts/SaleControl.sol` | sale toggles/limits |
| Deployment orchestration | `deploy/` | workspace hardhat-deploy scripts |

## CONVENTIONS
- Run this workspace independently (`npm run <script> --workspace=eip-2535` or from this directory).
- Respect local `hardhat.config.js`; do not assume root hardhat settings/artifacts.
- Keep diamond storage changes explicit and coordinated with facet logic.

## ANTI-PATTERNS
- Referencing root artifacts/tests from inside this workspace.
- Treating this workspace as interchangeable with root ERC721F contracts.
- Editing facet/storage layout casually without migration/compatibility reasoning.
