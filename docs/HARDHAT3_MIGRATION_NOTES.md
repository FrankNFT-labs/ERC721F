# Hardhat 3 Migration Notes

Executed 12-07-2026 on branch `chore/hardhat3-migration` (plan: [HARDHAT3_MIGRATION_PLAN.md](./HARDHAT3_MIGRATION_PLAN.md), issue #115).
Baseline/rollback point: commit `1918d9f` (Hardhat 2, 314 passing + 1 pending, forge 136 passing).

## Dependency set

| Package                                                     | Before             | After                                                                                                                                         |
| ----------------------------------------------------------- | ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `hardhat`                                                   | ^2.12.4            | ^3.9.1                                                                                                                                        |
| `@nomicfoundation/hardhat-toolbox`                          | ^2.0.0 (ethers v5) | replaced by `@nomicfoundation/hardhat-toolbox-mocha-ethers` ^3.0.7 (ethers v6, mocha 11, chai 6)                                              |
| `hardhat-gas-reporter`                                      | via toolbox        | **removed** — no Hardhat 3 release (peer `hardhat ^2.16.0`); replaced by Hardhat 3's built-in `hardhat test --gas-stats` / `--gas-stats-json` |
| `solidity-coverage`                                         | via toolbox        | replaced by Hardhat 3 built-in `hardhat test --coverage`                                                                                      |
| `hardhat-deploy` (EIP-2535 workspace)                       | ^1.0.4             | ^2.0.8 (rocketh-based rewrite) + `rocketh`, `@rocketh/deploy`, `@rocketh/diamond`, `@rocketh/node`, `@rocketh/read-execute`, `viem`           |
| `@nomiclabs/hardhat-ethers` (alias `hardhat-deploy-ethers`) | ^0.3.0-beta.13     | removed (superseded by toolbox `hardhat-ethers` v4)                                                                                           |

Both `package.json` files are now ESM (`"type": "module"`).

## Config changes

- Root and workspace `hardhat.config.js` use `defineConfig` + `plugins` array (ESM).
- The custom `TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS` filter is replaced by the
  explicit `paths.sources: ["contracts", "examples"]` array; node_modules, `lib/`,
  `.deps/` and `test/foundry` are no longer reachable because sources are opt-in.
- The `WHITELIST_PATH` / `WHITELIST_CONTRACT` env filters were removed; Hardhat 3
  supports file arguments natively:
  `npx hardhat compile <file.sol>` and `npx hardhat test <file.test.js>`.
- `paths.tests` scopes mocha to `./test/hardhat` and points the built-in solidity
  test runner away from `test/foundry` (forge remains the runner there).
- `solidity.npmFilesToBuild` compiles `VRFCoordinatorV2Mock` from
  `@chainlink/contracts` (replaces the Hardhat 2 shim-import trick for artifacts).
- A `production` build profile mirrors `default`; `hardhat deploy` compiles with it.

## Test-suite migration

- All mocha tests are ESM and share one network connection created in
  `test/hardhat/helpers/connection.js` (`await network.create()`), mirroring the
  single global network of Hardhat 2; isolation still comes from `loadFixture`.
- ethers v6 API: `.deployed()` → `.waitForDeployment()`, `ethers.utils.*` →
  `ethers.*`, `AddressZero` → `ZeroAddress`, contract `.address` → `.target`,
  BigNumber math → native bigint.
- Chai matcher changes: `.to.be.reverted` → `.to.revert(ethers)`,
  `changeEtherBalance(s)`/`changeTokenBalance(s)` take `ethers` as first argument.
- ethers v6 is stricter about types: `bytes`/`bytes4` arguments must be hex
  strings (`"0x00"`, `"0x80ac58cd"`), and `contract.connect()` needs a signer,
  not an address string.

### Latent test bugs surfaced by the stricter runner

Hardhat 3 fails the run on unawaited async assertions. Four pre-existing tests
in `Soulbound.test.js` asserted reverts on already-mined transactions sent by
the wrong signer (contract owner instead of the de-approved address), so they
never actually asserted anything under Hardhat 2. They now perform the transfer
or burn from the de-approved address and await the revert assertion. The burn
variant reverts with `TokenNotTransferable` (not `NotOwnerOrApproved`), matching
the neighbouring unauthorized-burn expectations, because `SoulboundMock.burn`
has no `onlyOwnerOrApproved` modifier and fails on transferability first.

### Workspace test spawning (important)

Hardhat 3 exports its global options as environment variables (notably
`HARDHAT_CONFIG`). The root wrapper test that spawns
`npm run test --workspace=eip-2535` must strip `HARDHAT_*` from the child env,
otherwise the workspace run loads the **root** config and recursively re-runs
the root suite (infinite loop). See `test/hardhat/examples/EIP-2535.test.js`.

## EIP-2535 workspace (hardhat-deploy v2)

- Deploy script rewritten to the rocketh `deployScript` form with
  `env.diamond(...)` from `@rocketh/diamond`; facets are passed as generated
  artifacts and `init` executes via `execute: { type: "facet", ... }`.
- New `rocketh/` folder: `config.js` (named accounts + extensions),
  `deploy.js` (deployScript + artifacts re-export), `environment.js`
  (`loadAndExecuteDeploymentsFromFiles` for test fixtures).
- Diamond solidity imports moved from `hardhat-deploy/solc_0.8/diamond/*` to
  `@rocketh/diamond/solc_0_8/*` (same library, new package).
- `generated/` (artifact modules) and `types/` (typechain) are build output
  and gitignored.
- Workspace scripts: `--export-all` and `etherscan-verify` were hardhat-deploy
  v1 features; `deploy`/`verify` now use the v2 task and `hardhat-verify`.

## Not migrated / follow-ups

- `REPORT_GAS=true npx hardhat test` no longer applies; gas reporting is now
  native via `npx hardhat test --gas-stats` (console table) or
  `--gas-stats-json <path>` (machine-readable). No plugin follow-up needed.
- `docs/HARDHAT3_MIGRATION_PLAN.md` retained for historical context.

## Verification (12-07-2026)

- `npx hardhat compile` — 61 files, green (root); 8 files, green (workspace)
- `npx hardhat test` — 315 passing, 0 failing (includes EIP-2535 workspace via wrapper)
- `npm run lint` — 0 errors (107 warnings, allowed)
- `npm run lint:foundry` — 0 errors, 0 warnings
- `forge test` — 136 passed, 0 failed (dev-mode example imports)
- `npx hardhat test --coverage` — built-in coverage report works
