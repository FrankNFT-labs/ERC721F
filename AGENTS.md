# PROJECT KNOWLEDGE BASE

**Reviewed:** 2026-08-08
**Commit:** d8b69f0
**Branch:** main

## OVERVIEW

ERC721F is a gas-optimized ERC721 implementation (Solidity 0.8.24, OpenZeppelin 5.7.0, EVM Cancun) with dual tooling: Hardhat + Foundry. Repo also contains production contracts, tests, and isolated examples (including an EIP-2535 workspace).

## STRUCTURE

```text
./
├── contracts/        # first-party production contracts
├── test/             # hardhat + foundry tests
├── examples/         # reference/example implementations
│   └── EIP-2535/     # isolated npm workspace
├── scripts/          # helper scripts (env/import/snapshot tooling)
├── docs/             # migration notes (md) + reference data/presentations
└── lib/              # vendored dependencies (exclude from ownership scans)
```

## WHERE TO LOOK

| Task                  | Location                                   | Notes                                |
| --------------------- | ------------------------------------------ | ------------------------------------ |
| Core token logic      | `contracts/token/ERC721/ERC721F.sol`       | total supply + wallet scan behavior  |
| Common extension base | `contracts/token/ERC721/ERC721FCOMMON.sol` | royalties + payable integration      |
| Utility patterns      | `contracts/utils/`                         | allowlist, operators, verify, random |
| Hardhat tests         | `test/hardhat/`                            | `.test.js` layout                    |
| Foundry tests         | `test/foundry/`                            | `.t.sol` layout                      |
| Example integrations  | `examples/*.sol`                           | import-path caveats apply            |
| Diamond example       | `examples/EIP-2535/`                       | own hardhat config/package           |

## CODE MAP

Solidity LSP is unavailable in this environment; use path-based mapping + AST/grep.

High-centrality modules:

- `contracts/token/ERC721/ERC721F.sol`
- `contracts/token/soulbound/Soulbound.sol`
- `contracts/utils/AllowList*.sol`
- `examples/EIP-2535/contracts/ERC721F/*`

## CONVENTIONS

- Solidity compiler pinned to `0.8.24` with optimizer runs `1000` (Hardhat + Foundry).
- Hardhat 3 stack: ESM project (`"type": "module"`), mocha tests share one
  network connection via `test/hardhat/helpers/connection.js`.
- Focused runs use Hardhat 3 built-in file arguments (the former
  `WHITELIST_PATH`/`WHITELIST_CONTRACT` env filters were removed).
- Tests are intentionally split by framework (`test/hardhat` vs `test/foundry`).
- Pre-commit flow applies formatting/lint and example import rewriting.

## ANTI-PATTERNS (THIS PROJECT)

- Treating `lib/forge-std` as first-party code (it is vendored dependency code).
- Running example tests without handling import-path expectations for examples.
- Assuming root artifacts are available inside `examples/EIP-2535` tests.
- Using mock contracts as production references (`contracts/mocks/*`).

## UNIQUE STYLES

- Gas-focused loops frequently use `unchecked` increments.
- Example contracts prioritize pedagogy/integration demos over minimal production surface.
- EIP-2535 example follows isolated workspace behavior rather than root-tool defaults.

## COMMANDS

```bash
# Root toolchain
npm ci                                # CI parity (npm install also works)
npx hardhat compile
npx hardhat test
npx hardhat test --coverage
forge build
forge test

# Lint / format
npm run lint                          # solhint over all .sol files
npm run lint:foundry                  # solhint with the foundry-test config
npm run prettier:solidity             # prettier + solidity plugin, writes in place

# Focused execution
npx hardhat compile contracts/token/ERC721/ERC721F.sol
npx hardhat test test/hardhat/token/ERC721/ERC721F.test.js
forge test --match-path "test/foundry/token/ERC721/ERC721FGasReporterMock.t.sol"

# Gas reporting
npx hardhat test --gas-stats          # Hardhat 3 built-in (replaces hardhat-gas-reporter)
forge test --gas-report               # Foundry-native

# Example import helpers
npm run update-example-imports:dev
npm run update-example-imports:prod
```

## NOTES

- If Hardhat example compilation fails on `@franknft.eth/erc721-f` imports, run `npm run update-example-imports:dev` to rewrite them to local paths (`:prod` restores the published form). CI runs `:dev` in both jobs before compiling.
- `examples/EIP-2535` has independent config; run it via `npm run <script> --workspace=eip-2535` or from that folder. Note the root `npm test` also exercises it: `test/hardhat/examples/EIP-2535.test.js` shells out to the workspace suite.
- CI is `.github/workflows/ci.yml`: two jobs ("Hardhat Tests", "Foundry Tests"), both `npm ci` + `update-example-imports:dev` first; triggers are push and pull_request on main only.
- `docs/` is reference material (md/xlsx/pdf/png), not part of compile/test pipeline.
