[![MIT License][license-shield]][license-url]
[![NPM][npm-shield]][npm-url]

# ERC721F

The goal of ERC721F is to provide a simple extension of IERC721 with significant gas savings for minting multiple and single NFTs in a single transaction. This project and implementation will be updated regularly and will continue to stay up to date with best practices.

ERC721F Extends ERC721 Non-Fungible Token Standard basic implementation. No longer uses ERC721Enumerable , but still provide a totalSupply() and walletOfOwner(address _owner) implementation.

The Author is not liable for any outcomes as a result of using ERC721F. **DYOR!**

<!-- ROADMAP -->

## Roadmap

- [] Add more documentation on benefits of using ERC721F
- [] Continue to try to reduce gas costs
- [] Start automated testing

See the [open issues](https://github.com/FrankNFT-labs/ERC721F/issues) for a full list of proposed features (and known issues).

<!-- USAGE EXAMPLES -->

## Usage
Just import the file directly from Gitlab like this:

```solidity
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9 <0.9.0;

import "https://github.com/FrankNFT-labs/ERC721F/blob/v4.7.1/contracts/token/ERC721/ERC721FCOMMON.sol";

contract Example is ERC721F {
    constructor() ERC721F("Example", "Example") {
        setBaseTokenURI("ipfs://QmVy7VQUFtTQawBsp4tbJPp9MgbTKS4L7WSDpZEdZUzsiD/"); 
    }

    /**
     * Mint your tokens here.
     */
    function mint(uint256 numberOfTokens) external {
        require(msg.sender==tx.origin,"No Contracts allowed.");
        uint256 supply = totalSupply();
        for(uint256 i; i < numberOfTokens;){
            _mint( msg.sender, supply + i ); // no need to use safeMint as we don't allow contracts.
            unchecked{ i++;}
        }
    }
}
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
1. Copy .env.example and rename to .env
2. `npm install`
3. `npx hardhat compile`
4. `npx hardhat test`
   
> **Warning**
> Since hardhat only compiles a single path at once, you'll probably fail every single test that's executed on solutions located in /examples. This is because those artifacts haven't been created yet.
These can be created by changing the the sources path in hardhat.config.js to "./examples" and executing step 3 again.

**Note:** `npx hardhat clean` removes the created artifacts

#### Running a single test
`npx hardhat test ./test/token/ERC721/GasUsage.test.js`

#### Testing gas consumption
- Enable the creation of a gas report by setting `REPORT_GAS` to `true` in `.env`
- Toggle the creation of a gas report file by (un)commenting `outputFile` in `hardhat.config.js` 
- Change the total runs and toggle the optimizer by changing the `solidity` `optimizer` values in `hardhat.config.js`

[license-shield]: https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge
[license-url]: https://github.com/FrankNFT-labs/ERC721F/blob/main/LICENSE
[npm-shield]: https://img.shields.io/npm/v/erc721a.svg?style=for-the-badge
[npm-url]: https://www.npmjs.com/package/erc721-f
