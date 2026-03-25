# Hardhat 3 Migration Plan (ERC721F)

## Executive Summary

This repository is currently on a Hardhat 2 toolchain and has validated compatibility with current test suites.
The direct dependency bump to `@nomicfoundation/hardhat-toolbox` latest was tested and found incompatible with the current stack.

This plan defines a dedicated migration track to Hardhat 3, with explicit acceptance criteria and rollback points.

---

## ADR (short)

### Context

- ERC721F currently uses:
    - root Hardhat config (`hardhat.config.js`)
    - isolated EIP-2535 Hardhat workspace (`examples/EIP-2535/hardhat.config.js`)
    - Hardhat test suite that exercises both root and EIP-2535 workspace
- Recent dependency upgrades (linting/formatting/hooks) are stable.
- Toolbox major upgrade (`@nomicfoundation/hardhat-toolbox` latest) caused runtime incompatibilities in the current Hardhat 2 setup.

### Decision

Run a dedicated Hardhat 3 migration in a separate branch/PR with phased validation gates.

### Consequences

- Safer than mixing migration with routine dependency bumps.
- Requires coordinated changes to plugin stack, config, and tests.
- Adds temporary migration overhead but reduces release risk.

---

## Scope

### In scope

- Root Hardhat stack migration to Hardhat 3-compatible versions.
- EIP-2535 workspace alignment.
- Test/API migration in Hardhat test files where runtime APIs changed.
- CI workflow checks and final verification matrix.

### Out of scope

- Contract logic changes unrelated to tooling.
- Gas optimization refactors.
- Foundry redesign (Foundry remains verification gate).

---

## Migration Phases

## Phase 0 — Baseline & Safety Rails

1. Create branch: `chore/hardhat3-migration`.
2. Freeze baseline evidence:
    - `npm run compile`
    - `npm run test`
    - `npm run lint`
    - `npm run lint:foundry`
    - `forge test`
3. Keep rollback tag/commit reference.

**Exit criteria:** baseline reproducible and green.

## Phase 1 — Dependency Graph Upgrade

1. Upgrade core Hardhat packages to Hardhat 3-compatible set.
2. Upgrade toolbox/plugins to the matching major versions.
3. Align workspace (`examples/EIP-2535/package.json`) with compatible deploy/plugin versions.

**Exit criteria:** `npm install` succeeds with no peer-resolution conflicts.

## Phase 2 — Config Migration

1. Migrate root `hardhat.config.js` to Hardhat 3 expectations.
2. Migrate `examples/EIP-2535/hardhat.config.js` similarly.
3. Validate custom subtasks/filters still execute correctly.

**Exit criteria:** `npm run compile` succeeds for root + workspace.

## Phase 3 — Test Runtime/API Migration

1. Migrate test API usage impacted by plugin/runtime changes.
2. Update assertions/util helpers where Ethers plugin surface changed.
3. Ensure workspace test invocation from root remains valid.

**Exit criteria:** `npm run test` passes fully.

## Phase 4 — CI & Tooling Hardening

1. Validate GitHub Actions workflow commands under migrated stack.
2. Keep lint + foundry gates unchanged.
3. Confirm release/readme automation still works.

**Exit criteria:** CI equivalent matrix green locally and on PR.

## Phase 5 — Release Readiness

1. Update README requirements if needed.
2. Add migration notes/changelog entry.
3. Merge only after all checks pass.

**Exit criteria:** release candidate is green end-to-end.

---

## Verification Matrix (must pass)

```bash
npm run compile
npm run test
npm run lint
npm run lint:foundry
forge test
```

Plus:

- EIP-2535 workspace tests via root test runner must pass.
- No regression in release workflow behavior.

---

## Risk Register

1. **Plugin incompatibility chain**
    - Mitigation: upgrade as a coherent set, not piecemeal.
2. **Ethers API drift in tests**
    - Mitigation: migrate tests in a single phase and run full suite after each change.
3. **Workspace drift (root vs EIP-2535)**
    - Mitigation: verify both configs and workspace test execution explicitly.

---

## Definition of Done

- Hardhat 3 stack installed without dependency conflicts.
- Root + workspace compile successfully.
- Full test/lint/foundry matrix green.
- CI workflows continue to pass.
- Migration notes documented in repo.
