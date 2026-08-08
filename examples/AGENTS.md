# AGENTS.md - examples/

Inherits from `../AGENTS.md`. This file lists example-subtree specifics only.

## OVERVIEW

Reference implementations for integration patterns (allowlist, merkle, on-chain metadata, proxy/delegation, VRF, and diamond).

## STRUCTURE

```text
examples/
├── *.sol                         # standalone reference contracts
├── mocks/                        # mock wrappers for example-focused tests
├── gas-optimisations/            # focused gas pattern demo(s)
├── proxy/                        # delegation/proxy patterns
└── EIP-2535/                     # isolated workspace (see child AGENTS)
```

## WHERE TO LOOK

| Goal                      | Location                                   | Notes                            |
| ------------------------- | ------------------------------------------ | -------------------------------- |
| Basic ERC721F mint flow   | `FreeMint.sol`                             | simple baseline example          |
| Allowlist sale            | `AllowList.sol`, `AllowListWithAmount.sol` | utility-mixin patterns           |
| Merkle whitelist          | `MerkleRoot.sol`                           | proof verification sale path     |
| VRF-based randomization   | `ChainLink.sol`                            | external coordinator assumptions |
| On-chain metadata         | `OnChain.sol`, `OnChainOptimized.sol`      | tokenURI generation strategies   |
| Metadata refresh events   | `ERC4906.sol`                              | EIP-4906 metadata-update signals |
| Cross-collection gating   | `ERC721FVerifyImplementation.sol`          | mint gated on FreeMint ownership |
| Non-core proxy/delegation | `proxy/*.sol`                              | standalone integration patterns  |

## CONVENTIONS

- Examples are pedagogical; they may prioritize clarity over production hardening.
- Example imports use the published package name; `npm run update-example-imports:dev` (root) rewrites them to local paths, `:prod` restores.
- Treat `EIP-2535/` as separate workspace semantics, not root defaults.

## ANTI-PATTERNS

- Assuming examples are production-hardened out of the box.
- Running example compiles/tests without first running `npm run update-example-imports:dev`.
- Mixing EIP-2535 artifact expectations with root artifact expectations.
