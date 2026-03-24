# AGENTS.md - examples/

Inherits from `../AGENTS.md`. This file lists example-subtree specifics only.

## OVERVIEW
Reference implementations for integration patterns (allowlist, merkle, on-chain metadata, operator filtering, proxy/delegation, VRF, and diamond).

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
| Goal | Location | Notes |
|------|----------|-------|
| Basic ERC721F mint flow | `FreeMint.sol` | simple baseline example |
| Allowlist sale | `AllowList.sol`, `AllowListWithAmount.sol` | utility-mixin patterns |
| Merkle whitelist | `MerkleRoot.sol` | proof verification sale path |
| VRF-based randomization | `ChainLink.sol` | external coordinator assumptions |
| On-chain metadata | `OnChain.sol`, `OnChainOptimized.sol` | tokenURI generation strategies |
| Operator filtering | `RevokableDefaultOperatorFiltererERC721F.sol` | operator registry constraints |
| Non-core proxy/delegation | `proxy/*.sol` | standalone integration patterns |

## CONVENTIONS
- Examples are pedagogical; they may prioritize clarity over production hardening.
- Example imports may need local-path switching for local compile/test.
- Treat `EIP-2535/` as separate workspace semantics, not root defaults.

## ANTI-PATTERNS
- Assuming examples are production-hardened out of the box.
- Running root hardhat flows against examples without adjusting import paths/source scope.
- Mixing EIP-2535 artifact expectations with root artifact expectations.
