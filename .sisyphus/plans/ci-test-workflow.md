# CI Test Workflow for PR and Push-to-Main

## TL;DR

> **Quick Summary**: Add `.github/workflows/ci.yml` with two parallel jobs (Hardhat + Foundry) that run on every PR and every push to main. Update README badge to point at the new workflow.
>
> **Deliverables**:
>
> - `.github/workflows/ci.yml` (new file)
> - `README.md` — 2-line badge update only
>
> **Estimated Effort**: Quick
> **Parallel Execution**: YES — 2 parallel jobs within ci.yml; plan tasks run sequentially (2 tasks, each small)
> **Critical Path**: Task 1 (ci.yml) → Task 2 (README badge)

---

## Context

### Original Request

Dependabot opened 2 PRs (dotenv bump #119, solhint bump #118). No CI tests ran on them. User confirmed no test CI workflow exists at all — `main.yml` only triggers on `release` and `workflow_dispatch`.

### Interview Summary

**Key Discussions**:

- Trigger scope: PR + push to main
- Test suites: Both Hardhat AND Foundry
- Job structure: Parallel (separate jobs, not sequential)

**Research Findings**:

- `.nvmrc` pins Node 24; `engines: >=24` in package.json
- `npm test` script exists (`npx hardhat test`)
- `.env` not required — dotenv is silent, no external services
- `remappings.txt` maps deps to `node_modules/` — Foundry job MUST `npm ci`
- Examples use production imports (`@franknft.eth/erc721-f`) — BLOCKER for Hardhat compile on fresh checkout
- `npm run update-example-imports:dev` must run BEFORE `npx hardhat compile`
- `actions/checkout@v6` used in main.yml (Dependabot manages action versions)
- EIP-2535 is a separate workspace — excluded from root tests

### Metis Review

**Identified Gaps** (addressed):

- **BLOCKER**: Hardhat compile fails on fresh checkout due to unresolvable example imports → fixed by adding `npm run update-example-imports:dev` step before compile
- **BLOCKER**: Foundry remappings require `node_modules/` → fixed by adding `npm ci` to Foundry job
- `npm ci` preferred over `npm install` for deterministic CI builds
- Use `node-version-file: '.nvmrc'` instead of hardcoded version string

### Execution Learnings (discovered during run)

- **Foundry also needs `update-example-imports:dev`**: Foundry test files under `test/foundry/examples/` import example contracts directly (e.g. `ERC4906.sol`, `FreeMintMock.sol`). Metis assumed `src = 'contracts'` excluded examples, but test imports pull them in. Both jobs need the rewrite step.
- **`pull_request_target` needed for Dependabot**: GitHub blocks standard `pull_request` CI on Dependabot branches by default. Added `pull_request_target` trigger. Full Dependabot CI (running on the PR itself before merge) requires enabling "Allow Dependabot to trigger workflows" in repo Settings → Security & analysis — UI-only, not settable via API.

---

## Work Objectives

### Core Objective

Ensure every PR and push to main automatically runs both Hardhat and Foundry test suites, giving Dependabot PRs (and all PRs) real test coverage.

### Concrete Deliverables

- `.github/workflows/ci.yml` — new workflow file
- `README.md` — badge references updated from `main.yml` to `ci.yml`

### Definition of Done

- [x] `ci.yml` is valid YAML
- [x] `main.yml` is unchanged
- [x] README badge URLs reference `ci.yml` not `main.yml`
- [x] `npx hardhat test` passes locally (after `update-example-imports:dev`)
- [x] `forge test` passes locally
- [x] CI passes on GitHub (Hardhat: success, Foundry: success — confirmed on run 24334277036)

### Must Have

- `on: pull_request` and `on: push: branches: [main]` triggers
- `hardhat` and `foundry` as separate parallel jobs (no `needs:` between them)
- `npm run update-example-imports:dev` step in Hardhat job BEFORE compile
- `npm ci` (not `npm install`) in both jobs
- `actions/setup-node` with `node-version-file: '.nvmrc'`
- `foundry-toolchain` action for Foundry install

### Must NOT Have (Guardrails)

- DO NOT touch `.github/workflows/main.yml`
- DO NOT set `WHITELIST_PATH`, `WHITELIST_CONTRACT`, or `REPORT_GAS`
- DO NOT add EIP-2535 workspace tests
- DO NOT add linting, coverage, gas reporting, or matrix builds
- DO NOT add caching in this iteration
- DO NOT add `needs:` dependency between hardhat and foundry jobs

---

## TODOs

- [x]   1. Create `.github/workflows/ci.yml`
    - Committed: `60f4e1b` — `ci: add test workflow for PR and push-to-main triggers`
    - Fixed Foundry import issue: `4bc6ba2` — `ci: add update-example-imports:dev step to Foundry job`
    - Added `pull_request_target`: `ca01e18` — `ci: add pull_request_target trigger for Dependabot PRs`

- [x]   2. Update README.md badge references
    - Both badge lines now point to `ci.yml` — committed in `60f4e1b`

---

## Final Verification Wave

- [x] F1. **Correctness check**

    `YAML [PASS] | main.yml [UNCHANGED] | Badge [PASS] | Hardhat [PASS] | Foundry [PASS] | VERDICT: APPROVE`

    GitHub Actions run 24334277036: Hardhat Tests ✓ | Foundry Tests ✓

---

## COMPLETED

**Status**: DONE  
**Commits shipped**:

- `60f4e1b` — ci: add test workflow for PR and push-to-main triggers
- `ca01e18` — ci: add pull_request_target trigger for Dependabot PRs
- `4bc6ba2` — ci: add update-example-imports:dev step to Foundry job

**Remaining action for Frank** (UI-only):  
Go to `Settings → Code security and analysis → Dependabot` and enable **"Allow Dependabot to trigger workflows"** to make CI run on future Dependabot PRs _before_ merge (not just on the merge commit).
