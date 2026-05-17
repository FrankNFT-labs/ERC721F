[![MIT License][license-shield]][license-url]
[![NPM][npm-shield]][npm-url]
[![Solidity][solidity-shield]][solidity-url]
[![Build][build-shield]][build-url]

# ERC721F

The goal of ERC721F is to provide a simple extension of IERC721 with significant gas savings for minting multiple and single NFTs in a single transaction. This project and implementation will be updated regularly and will continue to stay up to date with best practices.
Another key goal of ERC721F is to facilitate educational opportunities for new web3 developers, fostering a supportive learning environment and driving innovation within the community.

ERC721F extends ERC721 Non-Fungible Token Standard basic implementation. ERC721F eliminates the need for ERC721Enumerable, yet retains the functionality of totalSupply() and walletOfOwner(address \_owner).

The Author is not liable for any outcomes as a result of using ERC721F. **DYOR!**

<!-- LEARNING PATH -->

## Learning Path

ERC721F ships a set of progressively more advanced example contracts designed to onboard new Solidity developers step by step.
Each example builds on the previous one and introduces exactly one new concept.

| Step | Contract                                                                               | Concepts introduced                                             |
| ---- | -------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| 1    | [`examples/FreeMint.sol`](./examples/FreeMint.sol)                                     | Basic ERC721F usage, ERC-2981 royalties, EOA-only guard         |
| 2    | [`examples/AllowList.sol`](./examples/AllowList.sol)                                   | Utility mixin pattern, multiple inheritance, allowlist modifier |
| 3    | [`examples/AllowListWithAmount.sol`](./examples/AllowListWithAmount.sol)               | Per-address mint quota, internal state decrement                |
| 4    | [`examples/MerkleRoot.sol`](./examples/MerkleRoot.sol)                                 | Merkle-proof whitelisting, pre-sale / public-sale state machine |
| 5    | [`contracts/token/soulbound/Soulbound.sol`](./contracts/token/soulbound/Soulbound.sol) | Non-transferable tokens, EIP-5192, EIP-6454                     |
| 6    | [`examples/OnChain.sol`](./examples/OnChain.sol)                                       | On-chain SVG metadata, EIP-4883, string assembly                |
| 7    | [`examples/OnChainOptimized.sol`](./examples/OnChainOptimized.sol)                     | Bitfield trait packing — advanced storage optimization          |
| 8    | [`examples/ChainLink.sol`](./examples/ChainLink.sol)                                   | External oracle integration, Chainlink VRF callback pattern     |
| 9    | [`examples/EIP-2535/`](./examples/EIP-2535/)                                           | Diamond proxy (EIP-2535), upgradeability, facets                |

> Gas benchmarks comparing ERC721F against OpenZeppelin ERC721Enumerable are in [`BENCHMARK.md`](./BENCHMARK.md).

<!-- ROADMAP -->

## Roadmap

- [x] Add more documentation on benefits of using ERC721F
- [x] Continue to try to reduce gas costs
- [x] Start automated testing
- [x] Put package under Agentic AI control

See the [open issues](https://github.com/FrankNFT-labs/ERC721F/issues) for a full list of proposed features (and known issues).

## Security

Please refer to [SECURITY.md](./SECURITY.md) for our security policy and how to responsibly report vulnerabilities.

<!-- USAGE EXAMPLES -->

## Usage

### Installation

```
npm install '@franknft.eth/erc721-f'
```

### Requirements

- **Solidity**: `0.8.24` or higher
- **Node.js**: `>=24`
- **OpenZeppelin**: `5.6.1`

Just import the file from the package like this:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "@franknft.eth/erc721-f/contracts/token/ERC721/ERC721FCOMMON.sol";

contract Example is ERC721F {
    constructor() ERC721F("Example", "Example", msg.sender) {
        setBaseTokenURI(
            "ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/"
        );
    }

    /**
     * Mint your tokens here.
     */
    function mint(uint256 numberOfTokens) external {
        require(msg.sender == tx.origin, "No Contracts allowed.");
        uint256 supply = totalSupply();
        for (uint256 i; i < numberOfTokens; ) {
            _mint(msg.sender, supply + i); // no need to use safeMint as we don't allow contracts.
            unchecked {
                i++;
            }
        }
    }
}
```

Or just import the file directly from Gitlab like this:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 <0.9.0;

import "https://github.com/FrankNFT-labs/ERC721F/blob/v5.6.1/contracts/token/ERC721/ERC721FCOMMON.sol";
```

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Running tests locally

#### Hardhat

1. Copy .env.example and rename to .env
2. `nvm use`
3. `npm install`
4. `npx hardhat compile`
5. `npx hardhat test`

> **Warning**
> When running any test of a contract located in /examples, you'll receive a compilation error due to the @franknft.eth/erc721-f library not being installed.
> To prevent this error you must change all imports where @franknft.eth/erc721-f to the location of the local file. For example "../contracts/utils/AllowList.sol" in the AllowList example.

> **Warning**
> Since hardhat only compiles a single path at once, you'll probably fail every single test that's executed on solutions located in /examples. This is because those artifacts haven't been created yet.
> These can be created by changing the the sources path in hardhat.config.js to "./examples" and executing step 3 again.

**Note:** `npx hardhat clean` removes the created artifacts

##### Running a single test

`npx hardhat test ./test/token/ERC721/GasUsage.test.js`

##### Testing gas consumption

- Enable the creation of a gas report by setting `REPORT_GAS` to `true` in `.env`
- Toggle the creation of a gas report file by (un)commenting `outputFile` in `hardhat.config.js`
- Change the total runs and toggle the optimizer by changing the `solidity` `optimizer` values in `hardhat.config.js`

#### Foundry

1. Install [Rust](https://www.rust-lang.org/tools/install)
2. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
3. `forge build`
4. `forge test`

#### Running a single test

`forge test --match-path test\foundry\token\ERC721\ERC721FGasReporterMock.t.sol`

#### Testing gas consumption

`forge test --gas-report`

[license-shield]: https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge
[license-url]: https://github.com/FrankNFT-labs/ERC721F/blob/main/LICENSE
[npm-shield]: https://img.shields.io/npm/v/@franknft.eth/erc721-f.svg?style=for-the-badge
[npm-url]: https://www.npmjs.com/package/@franknft.eth/erc721-f
[solidity-shield]: https://img.shields.io/badge/Solidity-0.8.24-blue.svg?style=for-the-badge
[solidity-url]: https://soliditylang.org
[build-shield]: https://github.com/FrankNFT-labs/ERC721F/actions/workflows/ci.yml/badge.svg
[build-url]: https://github.com/FrankNFT-labs/ERC721F/actions/workflows/ci.yml
